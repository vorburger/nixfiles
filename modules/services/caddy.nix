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
          openFirewall = true;

          virtualHosts."hello.home.vorburger.ch".extraConfig = ''
            respond "hello, caddy!"
          '';
          # https://jellyfin.org/docs/general/post-install/networking/reverse-proxy/caddy/
          virtualHosts."vorbflix.home.vorburger.ch".extraConfig = ''
            reverse_proxy :8096
          '';
          # https://seerr.dev
          virtualHosts."seerr.home.vorburger.ch".extraConfig = ''
            reverse_proxy :5055
          '';
          # Enola2 UI & API (https://vaish.home.vorburger.ch)
          virtualHosts."vaish.home.vorburger.ch".extraConfig = ''
            handle /v1/* {
              reverse_proxy :2609
            }
            handle /widget/* {
              reverse_proxy :2609
            }
            handle {
              root * /var/lib/enola/ui
              try_files {path} /index.html
              file_server
            }
          '';
          # TODO Auth! WebAuthn, ideally... check github.com/greenpau/caddy-security, or Authelia or Authentik.
          # TODO Services overview welcome sort of page; static, or auto-generated?
          # TODO http://localhost/ should show ^^^ it
          # TODO http://home.vorburger.ch/ should show ^^^ it
          # TODO http://titan.home.vorburger.ch/ should show ^^^ it

          # TLS DNS challenge for Caddy's magic ACME (Let's Encrypt) certificates
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/googleclouddns@6fcdbd98a8565df50ff40ff53411dc6c8d97dcd9" ];
            hash = "sha256-okBp6jj+lEZNqrsEEoaMBA7ei4C9OTFNntiXAcb+4Z8=";
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
      };
  };
}
