let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.nixarr = {
    url = "github:nix-media-server/nixarr";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      treefmt-nix.follows = "treefmt-nix";
    };
  };

  flake.nixosModules.nixarr = mkService {
    name = "nixarr";
    description = "Nixarr media stack with Seerr, Radarr, Sonarr, Prowlarr, and Transmission";
    imports = [
      inputs.nixarr.nixosModules.default
    ];
    content = _: {
      nixarr = {
        enable = lib.mkDefault true;
        mediaDir = lib.mkDefault "/bardioc/public";
        stateDir = lib.mkDefault "/var/lib/nixarr";
        mediaUsers = lib.mkDefault [ "vorburger" ];

        # Seerr (seerr.dev): Web UI for media requests & discovery
        seerr = {
          enable = lib.mkDefault true;
          openFirewall = lib.mkDefault false;
        };

        # Servarr management stack
        radarr = {
          enable = lib.mkDefault true;
          openFirewall = lib.mkDefault false;
        };
        sonarr = {
          enable = lib.mkDefault true;
          openFirewall = lib.mkDefault false;
        };
        prowlarr = {
          enable = lib.mkDefault true;
          openFirewall = lib.mkDefault false;
          settings-sync.enable-nixarr-apps = lib.mkDefault true;
        };

        # Torrent download client
        transmission = {
          enable = lib.mkDefault true;
          openFirewall = lib.mkDefault false;
          peerPort = lib.mkDefault 51413;
        };

        # Declarative download client syncing
        sonarr.settings-sync.transmission.enable = lib.mkDefault true;
        radarr.settings-sync.transmission.enable = lib.mkDefault true;
      };

      # Settings required by nixarr settings-sync for local REST API calls on boot
      services.prowlarr.settings.auth.required = lib.mkDefault "DisabledForLocalAddresses";
      services.radarr.settings.auth.required = lib.mkDefault "DisabledForLocalAddresses";
      services.sonarr.settings.auth.required = lib.mkDefault "DisabledForLocalAddresses";

      # https://flaresolverr.com
      # https://github.com/FlareSolverr/FlareSolverr
      services.flaresolverr.enable = true;
    };
  };
}
