let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  inherit (import ../../lib/mk-service.nix) mkService;
  network = import ../../lib/homelab-network.nix;

  # Hardware admin keys capable of decrypting secrets on either machine
  adminRecipients = recipients: [
    recipients.portable-yubikey-9599730
    recipients.titan-yubikey-10300902
  ];

  # Strict per-host secret rules: titan's host key cannot decrypt ixo's secret and vice versa
  secretTitan = mkSecret {
    name = "wireguard-titan";
    moduleName = "_wireguard_titan";
    publicKeys = recipients: [ recipients.titan ] ++ adminRecipients recipients;
  };

  secretIxo = mkSecret {
    name = "wireguard-ixo";
    moduleName = "_wireguard_ixo";
    publicKeys = recipients: [ recipients.ixo ] ++ adminRecipients recipients;
  };
in
_: {
  flake.secretRules =
    recipients: (secretTitan.flake.secretRules recipients) // (secretIxo.flake.secretRules recipients);

  flake.nixosModules.wireguard = mkService {
    name = "wireguard";
    description = "WireGuard VPN service";
    extraOptions =
      { config, lib, ... }:
      let
        hostInfo = network.hosts.${config.networking.hostName} or { };
      in
      {
        role = lib.mkOption {
          type = lib.types.enum [
            "server"
            "client"
          ];
          default = hostInfo.role or "client";
          description = "WireGuard node role: server (listening on port) or client (connecting to server).";
        };

        interface = lib.mkOption {
          type = lib.types.str;
          default = "wg0";
          description = "WireGuard network interface name.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = network.port;
          description = "WireGuard UDP listen port (used by server).";
        };

        serverEndpoint = lib.mkOption {
          type = lib.types.str;
          default = network.serverEndpoint;
          description = "Public endpoint (host:port) that clients connect to.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to manage firewall rules for WireGuard.";
        };
      };

    content =
      {
        cfg,
        config,
        lib,
        ...
      }:
      let
        hostName = config.networking.hostName;
        secretName = "wireguard-${hostName}";
        currentHost =
          network.hosts.${hostName}
            or (throw "Host '${hostName}' has services.wireguard enabled, but is not defined in lib/homelab-network.nix");

        # Separate client hosts from server host
        clients = lib.filterAttrs (_name: h: (h.role or "client") == "client") network.hosts;
        trustedClients = lib.filterAttrs (_name: h: h.trusted or false) clients;
        serverHost = network.hosts.titan;
      in
      {
        # Decrypt only this host's private key into /run/secrets/wireguard-<hostName>
        age.secrets.${secretName} = {
          file = ../../secrets/encrypted + "/${secretName}.age";
          mode = "0400";
          owner = "root";
          group = "root";
        };

        # Ignore WireGuard interface in NetworkManager to prevent interference
        networking.networkmanager.unmanaged = [ "interface-name:${cfg.interface}" ];

        # Server-specific IP forwarding (dual-stack IPv4 & IPv6)
        boot.kernel.sysctl = lib.mkIf (cfg.role == "server") {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };

        # Firewall configuration
        networking.firewall = lib.mkIf cfg.openFirewall {
          # Open listen port on server
          allowedUDPPorts = lib.mkIf (cfg.role == "server") [ cfg.port ];

          # Clients trust their own wg0 interface
          trustedInterfaces = lib.mkIf (cfg.role == "client") [ cfg.interface ];

          # Server applies selective per-client access control:
          extraCommands = lib.mkIf (cfg.role == "server") ''
            # Allow established and related traffic on WireGuard interface
            iptables -A INPUT -i ${cfg.interface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
            ip6tables -A INPUT -i ${cfg.interface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

            # Allow ICMP ping from all WireGuard peers
            iptables -A INPUT -i ${cfg.interface} -p icmp -j ACCEPT
            ip6tables -A INPUT -i ${cfg.interface} -p ipv6-icmp -j ACCEPT

            # 1. Full access for trusted admin clients (e.g. ixo)
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                _name: h: "iptables -A INPUT -i ${cfg.interface} -s ${h.wireguardIpv4} -j ACCEPT"
              ) trustedClients
            )}
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                _name: h: "ip6tables -A INPUT -i ${cfg.interface} -s ${h.wireguardIpv6} -j ACCEPT"
              ) trustedClients
            )}

            # 2. Restricted access for untrusted/media clients (e.g. tablet): HTTP (80) & HTTPS (443) only
            iptables -A INPUT -i ${cfg.interface} -p tcp -m multiport --dports 80,443 -j ACCEPT
            ip6tables -A INPUT -i ${cfg.interface} -p tcp -m multiport --dports 80,443 -j ACCEPT

            # 3. Drop all other incoming traffic destined to server on WireGuard interface
            iptables -A INPUT -i ${cfg.interface} -j DROP
            ip6tables -A INPUT -i ${cfg.interface} -j DROP

            # --- Forwarding Access Control (transit & inter-client isolation) ---
            # Allow established and related forwarded traffic across WireGuard interface
            iptables -A FORWARD -i ${cfg.interface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
            ip6tables -A FORWARD -i ${cfg.interface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

            # Allow transit / inter-client forwarding only for trusted admin clients (e.g. ixo)
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                _name: h: "iptables -A FORWARD -i ${cfg.interface} -s ${h.wireguardIpv4} -j ACCEPT"
              ) trustedClients
            )}
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                _name: h: "ip6tables -A FORWARD -i ${cfg.interface} -s ${h.wireguardIpv6} -j ACCEPT"
              ) trustedClients
            )}

            # Drop all other forwarded traffic originating from WireGuard interface
            # (strictly isolates untrusted clients from other WireGuard peers and LAN devices)
            iptables -A FORWARD -i ${cfg.interface} -j DROP
            ip6tables -A FORWARD -i ${cfg.interface} -j DROP
          '';
        };

        # WireGuard interface configuration (Dual-Stack IPv4 + IPv6)
        networking.wireguard.interfaces.${cfg.interface} = {
          ips = [
            "${currentHost.wireguardIpv4}/24"
            "${currentHost.wireguardIpv6}/64"
          ];
          listenPort = lib.mkIf (cfg.role == "server") cfg.port;
          privateKeyFile = "/run/secrets/${secretName}";

          peers =
            if cfg.role == "server" then
              lib.mapAttrsToList (_name: h: {
                inherit (h) publicKey;
                allowedIPs = [
                  "${h.wireguardIpv4}/32"
                  "${h.wireguardIpv6}/128"
                ];
              }) clients
            else
              [
                {
                  # titan server
                  inherit (serverHost) publicKey;
                  endpoint = cfg.serverEndpoint;
                  allowedIPs = [
                    network.subnets.ipv4
                    network.subnets.ipv6
                    "${serverHost.lanIpv4}/32" # Route Titan's LAN IP directly over VPN without subnet collisions!
                  ];
                  persistentKeepalive = 25;
                  dynamicEndpointRefreshSeconds = 300;
                }
              ];
        };
      };
  };
}
