let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  inherit (import ../../lib/mk-service.nix) mkService;
  secret = mkSecret {
    name = "caddy-gcp-sa";
    moduleName = "caddy-extra";
    mode = "0400";
    owner = "caddy";
    group = "caddy";
  };
in
{ lib, ... }:
lib.recursiveUpdate secret {
  flake.nixosModules.caddy-extra = mkService {
    name = "caddy-extra";
    description = "Caddy web server for homelab";
    content =
      { pkgs, ... }:
      lib.recursiveUpdate secret.flake.nixosModules.caddy-extra {
        # https://wiki.nixos.org/wiki/Caddy
        services.caddy = {
          enable = true;
          openFirewall = false; # TODO reverse_proxy for all services, so that we can open the firewall for Caddy and close for all the other HTTP services

          virtualHosts."hello.home.vorburger.ch".extraConfig = ''
            respond "hello, caddy!"
          '';
          virtualHosts."vorbflix.home.vorburger.ch".extraConfig = ''
            reverse_proxy :8096
          '';
          # TODO Does Jellyfin Chromecast work with reverse_proxy? Does it need TLS?
          # TODO Auth! WebAuthn, ideally... check github.com/greenpau/caddy-security, or Authelia or Authentik.
          # TODO Services overview welcome sort of page; static, or auto-generated?
          # TODO http://localhost/ should show ^^^ it
          # TODO http://home.vorburger.ch/ should show ^^^ it
          # TODO http://titan.home.vorburger.ch/ should show ^^^ it

          # TLS DNS challenge for Caddy's magic ACME (Let's Encrypt) certificates
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/googleclouddns@v1.1.0" ];
            hash = "sha256-xPEfXARsV1ACfaN74i7ZDgT2N8MMbGZByqvOvNzTKMs=";
          };
          globalConfig = ''
            acme_dns googleclouddns {
              gcp_project "dns-vorburger"
            }
          '';
        };

        systemd.services.caddy.serviceConfig.Environment = [
          "GCP_PROJECT=dns-vorburger"
          "GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/caddy-gcp-sa"
          "GCP_APPLICATION_CREDENTIALS=/run/secrets/caddy-gcp-sa"
        ];

        # DNS
        services.coredns = {
          enable = true;
          config = ''
            . {
              hosts {
                # TODO Automagically add all virtualHosts!
                # TODO Use "IP of host", instead of hard-coding 192.168.1.99...
                192.168.1.99 hello.home.vorburger.ch vorbflix.home.vorburger.ch
                fallthrough
              }
              # TODO Use "IP of network's default DNS", instead of hard-coding 192.168.1.1...
              forward . 192.168.1.1 # Forward everything else to upstream
            }
          '';
        };
        # Use our very own DNS server (CoreDNS, above) for all lookups,
        # so that we can resolve our own local hostnames (like hello.home.vorburger.ch).
        # Alternatively, configure this host's IP on the home router's DHCP DNS setting.
        # This works for networkmanager from networking-extra.nix, but needs to be changed if we're ever switching to systemd-resolved or other.
        networking.nameservers = [ "127.0.0.1" ];
      };
  };
}
