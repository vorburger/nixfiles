# WireGuard VPN

This document describes the WireGuard VPN mesh architecture in `nixfiles` implemented by `modules/services/wireguard.nix` and configured centrally via `lib/homelab-network.nix`.

---

## Central Network Configuration (`lib/homelab-network.nix`)

To prevent hardcoding IP addresses, public keys, and host roles across multiple Nix files, all network topology parameters are centralized in `lib/homelab-network.nix`.

Both `modules/services/wireguard.nix` and individual host configurations import this single source of truth:

```nix
# lib/homelab-network.nix
{
  domain = "home.vorburger.ch";
  serverEndpoint = "vinea.internet-box.ch:51820";
  port = 51820;

  subnets = {
    ipv4 = "10.25.75.0/24";
    ipv6 = "fd25:75::/64";
  };

  hosts = {
    titan = {
      role = "server";
      lanIpv4 = "192.168.1.99";
      wireguardIpv4 = "10.25.75.1";
      wireguardIpv6 = "fd25:75::1";
      publicKey = "UVdA/6vjg/5mq+re3rnKzWUJvdqCPC/ObHQSFTUDqDg=";
      trusted = true;
    };

    ixo = {
      role = "client";
      wireguardIpv4 = "10.25.75.2";
      wireguardIpv6 = "fd25:75::2";
      publicKey = "vkzl9tUdw+9EZdClKirFaygTVo5C2PqjPs9DJ8MuqhI=";
      trusted = true; # Admin workstation: full access to SSH, Caddy, metrics, etc.
    };
  };
}
```

---

## Architecture & Topology

The WireGuard network forms a hub-and-spoke mesh topology where `titan` acts as the central VPN server/router, and workstations, laptops, and mobile devices connect as clients.

```
                    ┌────────────────────────┐
                    │  Home Router / DynDNS  │
                    │ vinea.internet-box.ch  │
                    │   (UDP 51820 forward)  │
                    └───────────┬────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │  titan (Server) │
                       │   10.25.75.1    │
                       │   fd25:75::1    │
                       └────────┬────────┘
                                │
               ┌────────────────┴────────────────┐
               ▼                                 ▼
      ┌─────────────────┐               ┌─────────────────┐
      │   ixo (Client)  │               │ Future Clients  │
      │   10.25.75.2    │               │  10.25.75.3+    │
      │   fd25:75::2    │               │  fd25:75::3+    │
      └─────────────────┘               └─────────────────┘
```

### Addressing & Dual-Stack IPv4 / IPv6

The network operates as a native **dual-stack** mesh:

| Host            | Role   | WireGuard IPv4  | WireGuard IPv6 (ULA) | Trust Level | Endpoint                           |
| :-------------- | :----- | :-------------- | :------------------- | :---------- | :--------------------------------- |
| **`titan`**     | Server | `10.25.75.1/24` | `fd25:75::1/64`      | `trusted`   | `192.168.1.99` (LAN) / UDP `51820` |
| **`ixo`**       | Client | `10.25.75.2/24` | `fd25:75::2/64`      | `trusted`   | `vinea.internet-box.ch:51820`      |
| _Future Tablet_ | Client | `10.25.75.3/24` | `fd25:75::3/64`      | Restricted  | `vinea.internet-box.ch:51820`      |

- **IPv4 Subnet**: `10.25.75.0/24` (avoids common `192.168.0.0/24` and `192.168.1.0/24` ranges).
- **IPv6 ULA Subnet**: `fd25:75::/64` (RFC 4193 Unique Local Addresses; globally collision-free and routable over cellular 5G networks).
- **Dynamic DNS Endpoint**: `vinea.internet-box.ch:51820`.
- **Dynamic Endpoint Refresh**: Client peers are configured with `dynamicEndpointRefreshSeconds = 300` to automatically re-resolve DynDNS if the home IP address changes.
- **Persistent Keepalive**: Clients send keepalives every 25 seconds (`persistentKeepalive = 25`) to keep stateful NAT firewalls open.

---

## Remote Routing & Subnet Collision Avoidance

Public DNS resolves `*.home.vorburger.ch` (such as `vorbflix.home.vorburger.ch`) to Titan's LAN IP `192.168.1.99`.

### The Subnet Collision Problem

If the client routed the entire `192.168.1.0/24` subnet over WireGuard, connecting to a hotel, cafe, or friend's WiFi that also uses `192.168.1.0/24` would break: local gateway packets would be intercepted by the tunnel, severing local network and internet connectivity.

### The Solution: `/32` Host Routing

Clients include `192.168.1.99/32` in `allowedIPs`:

```nix
allowedIPs = [
  network.subnets.ipv4
  network.subnets.ipv6
  "${serverHost.lanIpv4}/32" # 192.168.1.99/32
];
```

Because a `/32` host route has the highest specificity in CIDR routing:

1. Packets for `192.168.1.99` (`vorbflix.home.vorburger.ch`, `titan.home.vorburger.ch`) are cleanly tunneled over WireGuard to Titan from anywhere (5G tethering, foreign WiFis).
2. The rest of the local `192.168.1.x` subnet on the remote WiFi remains completely untouched, eliminating routing collisions.
3. Direct WireGuard IPs (`10.25.75.1` and `fd25:75::1`) are always available as collision-free alternatives.

---

## Role-Based Firewall Access Control

Rather than blanket-trusting all WireGuard traffic, Titan enforces **role-based packet filtering** on `wg0` across both local access (`INPUT`) and transit forwarding (`FORWARD`):

1. **Local Server Access (`INPUT` Chain on Titan)**:
   - **Trusted Admin Workstations (`ixo`)**: Matches `trusted = true` in `lib/homelab-network.nix`. Permitted full access to all ports on Titan: SSH (`22`), Caddy (`80`/`443`), metrics (`9100`/`9633`), Prometheus (`9090`), etc.
   - **Restricted Media Clients (`tablet`, mobile phones)**: Matches `trusted = false` in `lib/homelab-network.nix`. Permitted **only** HTTP (`80`) and HTTPS (`443`) on Titan to reach Caddy (Vorbflix, Seerr, Enola UI) plus ICMP ping. All other ports on Titan are dropped.

2. **Inter-Host Forwarding & Transit Isolation (`FORWARD` Chain on Titan)**:
   - **Trusted Admin Workstations (`ixo`)**: Permitted to route transit traffic through Titan to other WireGuard clients or LAN devices.
   - **Restricted Media Clients (`tablet`)**: Transit and inter-client routing is strictly blocked (`iptables -A FORWARD -i wg0 -j DROP`). Untrusted clients can **never** route through Titan to reach other peers (like `ixo`) or local LAN devices.

---

## Secrets Management & Host Isolation

Private keys are managed with `ragenix` per [Secrets Management](secrets.md).

- **Runtime Permissions**: Decrypted into RAM at `/run/secrets/wireguard-<host>` with `0400` ownership (`root:root`).
- **Cryptographic Host Isolation**:
  - `secrets/encrypted/wireguard-titan.age` is encrypted **only** to Titan's SSH host key and admin hardware keys.
  - `secrets/encrypted/wireguard-ixo.age` is encrypted **only** to Ixo's SSH host key and admin hardware keys.
  - Neither host can decrypt the other's private key.
- **Activation Isolation**: Each host activates only its own secret (`age.secrets.wireguard-${config.networking.hostName}`).
- **NixOS vs. Mobile Clients**:
  - `titan` and `ixo` are declarative NixOS hosts: their WireGuard interfaces are configured by systemd at boot, requiring their private keys to exist at `/run/secrets/wireguard-<host>`. Hence, they are encrypted into `secrets/encrypted/` via `ragenix`.
  - WireGuard is asymmetric cryptography (Curve25519). A peer **never** shares its private key with the server—`titan` only needs each client's `publicKey` in `lib/homelab-network.nix`.
  - Mobile clients (Android, iOS) store their private key locally in the app's secure OS keystore. Therefore, mobile private keys are **not** added to `ragenix`.

---

## Adding Future Clients (e.g. Android Tablet / Mobile)

To onboard a new client (such as an Android tablet) using the WireGuard Android client's **Scan from QR code** feature:

1. **Generate Keypair**:

   On your workstation (`ixo`), generate the private and public key pair:

   ```bash
   TABLET_PRIV=$(nix shell nixpkgs#wireguard-tools --command wg genkey)
   TABLET_PUB=$(echo "$TABLET_PRIV" | nix shell nixpkgs#wireguard-tools --command wg pubkey)
   echo "Public Key: $TABLET_PUB"
   ```

2. **Register Client in `lib/homelab-network.nix`**:

   Add the client definition to the `hosts` attribute set:

   ```nix
   tablet = {
     role = "client";
     wireguardIpv4 = "10.25.75.3";
     wireguardIpv6 = "fd25:75::3";
     publicKey = "<TABLET_PUB>";
     trusted = false; # Restricted: web ports (80/443) only for media streaming
   };
   ```

3. **Deploy Configuration to Titan**:

   Commit and push the updated network configuration, then rebuild Titan:

   ```bash
   git commit -am "feat(wireguard): add tablet client" && git push
   # On titan: git pull && nh os switch .
   ```

4. **Generate QR Code in Terminal**:

   Render the WireGuard client configuration directly as a QR code in your terminal using `qrencode`. For untrusted media clients, `AllowedIPs` includes only Titan's addresses (`10.25.75.1/32`, `fd25:75::1/128`, `192.168.1.99/32`) rather than the entire subnet, ensuring client-level routing isolation:

   ```bash
   cat <<EOF | nix shell nixpkgs#qrencode --command qrencode -t ansiutf8
   [Interface]
   PrivateKey = $TABLET_PRIV
   Address = 10.25.75.3/24, fd25:75::3/64

   [Peer]
   PublicKey = UVdA/6vjg/5mq+re3rnKzWUJvdqCPC/ObHQSFTUDqDg=
   Endpoint = vinea.internet-box.ch:51820
   AllowedIPs = 10.25.75.1/32, fd25:75::1/128, 192.168.1.99/32
   PersistentKeepalive = 25
   EOF
   ```

   > [!TIP]
   >
   > - **Terminal Contrast**: If your terminal uses a light theme and the camera has difficulty scanning, pass `-t ansiutf8i` to invert module colors.
   > - **Image Viewer Alternative**: You can also render to a temporary PNG file (`-t png -o /tmp/tablet-wg.png`), open it with an image viewer (`xdg-open /tmp/tablet-wg.png`), and scan from the screen. Delete the file (`rm /tmp/tablet-wg.png`) once scanned so the private key is not stored unencrypted on disk.

5. **Scan and Connect on Android**:

   1. Open the **WireGuard** app on the Android tablet.
   2. Tap the floating **`+`** (Add tunnel) button in the bottom right corner.
   3. Select **Scan from QR code**.
   4. Point the tablet camera at the QR code displayed in the terminal.
   5. Enter a tunnel name (e.g., `homelab` or `titan`) and tap **Create Tunnel**.
   6. Toggle the tunnel switch on to connect and test browsing to `http://vorbflix.home.vorburger.ch`.

---

## Diagnostics & Verification

Check interface status, IPs, and handshakes:

```bash
sudo wg show
```

Check systemd service logs:

```bash
journalctl -u wireguard-wg0 -n 50 --no-pager
```

Test IPv4 and IPv6 connectivity across the tunnel:

```bash
# IPv4
ping -c 3 10.25.75.1

# IPv6 ULA
ping -c 3 fd25:75::1

# Titan LAN host route over VPN
ping -c 3 192.168.1.99
```
