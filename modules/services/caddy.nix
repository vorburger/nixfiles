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
        # TODO Remove http: (default is https:) once we have magic TLS working...
        virtualHosts."http://hello.home.vorburger.ch".extraConfig = ''
          respond "hello, caddy!"
        '';
        virtualHosts."http://vorbflix.home.vorburger.ch".extraConfig = ''
          reverse_proxy :8096
        '';
        # TODO Does Jellyfin Chromecast work with reverse_proxy? Does it need TLS?
        # TODO Auth! WebAuthn, ideally... check github.com/greenpau/caddy-security, or Authelia or Authentik.
        # TODO Services overview welcome sort of page; static, or auto-generated?
        # TODO http://localhost/ should show ^^^ it
        # TODO http://home.vorburger.ch/ should show ^^^ it
        # TODO http://titan.home.vorburger.ch/ should show ^^^ it
      };

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
