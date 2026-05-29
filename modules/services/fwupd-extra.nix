let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.fwupd-extra = mkService {
    name = "fwupd-extra";
    description = "firmware update support (fwupd and redistributable firmware)";
    content = {
      services.fwupd.enable = true;
      hardware.enableRedistributableFirmware = true;
    };
  };
}
