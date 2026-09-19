# WireGuard VPN

This document describes the WireGuard VPN mesh architecture in `nixfiles` implemented by `modules/services/wireguard.nix`.

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
                       └────────┬────────┘
                                │
               ┌────────────────┴────────────────┐
               ▼                                 ▼
      ┌─────────────────┐               ┌─────────────────┐
      │   ixo (Client)  │               │ Future Clients  │
      │   10.25.75.2    │               │  10.25.75.3+    │
      └─────────────────┘               └─────────────────┘
```

### Addressing & Endpoints

| Host            | Role   | WireGuard IP    | Endpoint                                  | Listen Port   |
| :-------------- | :----- | :-------------- | :---------------------------------------- | :------------ |
| **`titan`**     | Server | `10.25.75.1/24` | `192.168.1.99` (LAN) / router port 51820  | `51820` (UDP) |
| **`ixo`**       | Client | `10.25.75.2/24` | Connects to `vinea.internet-box.ch:51820` | Dynamic       |
| _Future Client_ | Client | `10.25.75.3/24` | Connects to `vinea.internet-box.ch:51820` | Dynamic       |

- **Subnet**: `10.25.75.0/24`
- **Dynamic DNS Endpoint**: `vinea.internet-box.ch:51820`
- **Dynamic Endpoint Refresh**: Client peers are configured with `dynamicEndpointRefreshSeconds = 300` to automatically re-resolve DynDNS if the home IP address changes.
- **Persistent Keepalive**: Clients send keepalives every 25 seconds (`persistentKeepalive = 25`) to keep stateful NAT firewalls open.

---

## Secrets Management & Isolation

Private keys are managed with `ragenix` per [Secrets Management](secrets.md).

### Access Controls & Permissions

1. **Runtime Permissions**: Decrypted into RAM at `/run/secrets/wireguard-<host>` with `0400` ownership (`root:root`). Unprivileged users cannot read private keys.
2. **Cryptographic Host Isolation**:
   - `secrets/encrypted/wireguard-titan.age` is encrypted **only** to Titan's SSH host key and admin hardware keys (YubiKey / TPM). The `ixo` machine's SSH key cannot decrypt it.
   - `secrets/encrypted/wireguard-ixo.age` is encrypted **only** to Ixo's SSH host key and admin hardware keys (YubiKey / TPM). The `titan` machine's SSH key cannot decrypt it.
3. **Activation Isolation**: Each host activates only its own secret (`age.secrets.wireguard-${config.networking.hostName}`).

---

## Step-by-Step: Initial Key Generation

To prevent private keys from entering LLM context or remote logs, generate the keys locally in your terminal:

### 1. Generate Real Keys and Encrypt into Secrets

Run the following commands directly in your local terminal from the root of `nixfiles` in `bash`:

```bash
# Generate keys directly in temporary shell variables
TITAN_PRIV=$(nix shell nixpkgs#wireguard-tools --command wg genkey)
TITAN_PUB=$(echo "$TITAN_PRIV" | nix shell nixpkgs#wireguard-tools --command wg pubkey)

IXO_PRIV=$(nix shell nixpkgs#wireguard-tools --command wg genkey)
IXO_PUB=$(echo "$IXO_PRIV" | nix shell nixpkgs#wireguard-tools --command wg pubkey)

# Encrypt private keys into .age files
echo "$TITAN_PRIV" | ragenix --editor - --rules secrets/rules.nix -i $HOME/.config/age/identities -e secrets/encrypted/wireguard-titan.age
echo "$IXO_PRIV" | ragenix --editor - --rules secrets/rules.nix -i $HOME/.config/age/identities -e secrets/encrypted/wireguard-ixo.age

# Display public keys
echo "Titan Public Key: $TITAN_PUB"
echo "Ixo Public Key:   $IXO_PUB"
```

Because we're running this in Bash instead of Fish, this doesn't use [our `ragenix` Fish shell alias](secrets.md#create-or-edit-a-secret-file), and we thus explicitly pass `--rules` and `-i`. Passing `--editor -` allows `ragenix` to read the private key directly from standard input without attempting to launch an interactive editor (see [Writing Secrets Non-Interactively](secrets.md#writing-secrets-non-interactively-from-stdin)).

### 2. Update Public Keys in Module

Update `publicKeys` in `modules/services/wireguard.nix`:

```nix
publicKeys = {
  titan = "<TITAN_PUB>";
  ixo = "<IXO_PUB>";
};
```

### 3. Deploy and Switch

On `ixo`:

```bash
git commit -am "security(wireguard): update with real keys"
nh os switch .
```

On `titan`:

```bash
git pull
nh os switch .
```

---

## Adding Future Clients

To add a new client (e.g. `nixos-laptop` or a mobile phone):

1. **Assign an IP**: e.g., `10.25.75.3/24`.
2. **Generate Keypair**:

   ```bash
   CLIENT_PRIV=$(wg genkey)
   CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)
   ```

3. **Register Public Key on Server**:
   In `modules/services/wireguard.nix`, add the new peer to `publicKeys` and `peers` on the server:

   ```nix
   {
     publicKey = publicKeys.laptop;
     allowedIPs = [ "10.25.75.3/32" ];
   }
   ```

4. **Configure Client**:
   For NixOS clients, configure `services.wireguard.enable = true;`.
   For mobile devices (Android/iOS), configure the WireGuard app with:
   - **Interface Address**: `10.25.75.3/24`
   - **Peer Public Key**: `<TITAN_PUB>`
   - **Endpoint**: `vinea.internet-box.ch:51820`
   - **Allowed IPs**: `10.25.75.0/24`
   - **Persistent Keepalive**: `25`

---

## Diagnostics & Verification

Check interface status and handshakes:

```bash
sudo wg show
```

Check systemd service logs:

```bash
journalctl -u wireguard-wg0 -n 50 --no-pager
```

Test connectivity across the tunnel:

```bash
# From ixo:
ping -c 3 10.25.75.1

# From titan:
ping -c 3 10.25.75.2
```
