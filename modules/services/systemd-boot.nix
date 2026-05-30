let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.systemd-boot = mkService {
    name = "systemd-boot";
    description = "systemd-boot configuration";
    content =
      { config, lib, ... }:
      lib.mkIf config.boot.loader.systemd-boot.enable {
        boot.loader.systemd-boot.configurationLimit = 7;
      };
  };
}
