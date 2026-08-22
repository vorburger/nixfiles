{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.podman-extra = mkService {
    name = "podman-extra";
    description = "Podman container engine with Docker compatibility";
    extraOptions = {
      dockerCompat = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Create an alias/symlink for docker -> podman.";
      };
      dockerSocket = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the Docker-compatible socket.";
      };
      autoPrune = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Periodically prune unused containers, images, and volumes.";
      };
      searchRegistries = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "docker.io"
        ];
        description = "Unqualified-search registries for short image names (e.g. ubuntu -> docker.io/library/ubuntu).";
      };
    };
    content =
      { cfg, options, ... }:
      {
        virtualisation.podman = {
          enable = true;
          inherit (cfg) dockerCompat;
          dockerSocket.enable = cfg.dockerSocket;
          defaultNetwork.settings.dns_enabled = true;
          autoPrune = {
            enable = cfg.autoPrune;
            dates = "weekly";
            flags = [ "--all" ];
          };
        };

        virtualisation.containers.registries =
          if options.virtualisation.containers.registries ? settings then
            {
              settings.unqualified-search-registries = cfg.searchRegistries;
            }
          else
            {
              search = cfg.searchRegistries;
            };
      };
  };
}
