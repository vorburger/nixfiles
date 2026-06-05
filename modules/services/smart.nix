let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.smart = mkService {
    name = "smart";
    description = "SMART stuff";
    content =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        environment.systemPackages = [
          pkgs.smartmontools
        ]
        ++ lib.optional config.hardware.graphics.enable pkgs.gsmartcontrol;
      };
  };
}
