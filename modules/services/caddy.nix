let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  # https://wiki.nixos.org/wiki/Caddy
  flake.nixosModules.caddy-extra = mkService {
    name = "caddy-extra";
    description = "Caddy web server for homelab";
    content = {
      services.caddy = {
        enable = true;
        openFirewall = false; # TODO reverse_proxy for all services, so that we can open the firewall for Caddy and close for all the other HTTP services
        virtualHosts."localhost".extraConfig = ''
          respond "hello, caddy!"
        '';
        # TODO hello.home.vorburger.ch, with DNS
        # TODO reverse_proxy :
        # TODO https://wiki.nixos.org/wiki/Caddy "tls internal" - needed by Chromecast?
        # TODO Services overview welcome sort of page; static, or auto-generated?
      };
    };
  };
}
