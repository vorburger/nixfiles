let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  inherit (import ../../lib/mk-service.nix) mkService;

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

  # Known public keys for WireGuard peers
  # (Update these with real public keys generated via the terminal procedure in docs/docs/reference/wireguard.md)
  publicKeys = {
    titan = "UVdA/6vjg/5mq+re3rnKzWUJvdqCPC/ObHQSFTUDqDg=";
    ixo = "vkzl9tUdw+9EZdClKirFaygTVo5C2PqjPs9DJ8MuqhI=";
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
      {
        role = lib.mkOption {
          type = lib.types.enum [
            "server"
            "client"
          ];
          default = "client";
          description = "WireGuard node role: server (listening on port) or client (connecting to server).";
        };

        interface = lib.mkOption {
          type = lib.types.str;
          default = "wg0";
          description = "WireGuard network interface name.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 51820;
          description = "WireGuard UDP listen port (used by server).";
        };

        serverEndpoint = lib.mkOption {
          type = lib.types.str;
          default = "vinea.internet-box.ch:51820";
          description = "Public endpoint (host:port) that clients connect to.";
        };

        address = lib.mkOption {
          type = lib.types.str;
          default =
            if config.services.wireguard.role == "server" then
              "10.25.75.1/24"
            else if config.networking.hostName == "ixo" then
              "10.25.75.2/24"
            else
              "10.25.75.2/24";
          description = "WireGuard IPv4 address and CIDR prefix for this interface.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to open the UDP port on the firewall for server, and trust the wg0 interface.";
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
        secretName = "wireguard-${config.networking.hostName}";
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

        # Firewall configuration
        networking.firewall.trustedInterfaces = lib.mkIf cfg.openFirewall [ cfg.interface ];
        networking.firewall.allowedUDPPorts = lib.mkIf (cfg.openFirewall && cfg.role == "server") [
          cfg.port
        ];

        # Server-specific IP forwarding
        boot.kernel.sysctl = lib.mkIf (cfg.role == "server") {
          "net.ipv4.ip_forward" = 1;
        };

        # WireGuard interface configuration
        networking.wireguard.interfaces.${cfg.interface} = {
          ips = [ cfg.address ];
          listenPort = lib.mkIf (cfg.role == "server") cfg.port;
          privateKeyFile = "/run/secrets/${secretName}";

          peers =
            if cfg.role == "server" then
              [
                {
                  # ixo client
                  publicKey = publicKeys.ixo;
                  allowedIPs = [ "10.25.75.2/32" ];
                }
              ]
            else
              [
                {
                  # titan server
                  publicKey = publicKeys.titan;
                  endpoint = cfg.serverEndpoint;
                  allowedIPs = [ "10.25.75.0/24" ];
                  persistentKeepalive = 25;
                  dynamicEndpointRefreshSeconds = 300;
                }
              ];
        };
      };
  };
}
