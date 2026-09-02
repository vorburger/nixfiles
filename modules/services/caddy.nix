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
          # TODO Auth! WebAuthn, ideally... check github.com/greenpau/caddy-security, or Authelia or Authentik.
          # TODO Services overview welcome sort of page; static, or auto-generated?
          # TODO http://localhost/ should show ^^^ it
          # TODO http://home.vorburger.ch/ should show ^^^ it
          # TODO http://titan.home.vorburger.ch/ should show ^^^ it

          # TLS DNS challenge for Caddy's magic ACME (Let's Encrypt) certificates
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/googleclouddns@v1.1.0" ];
            hash = "sha256-lYsHQut0bb3laihMRIFi+gDiN2dAJCAa+sGDi4oTmjA=";
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
