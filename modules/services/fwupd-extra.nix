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

      security.polkit.enable = true;
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.freedesktop.fwupd.get-remotes" ||
               action.id == "org.freedesktop.fwupd.refresh-remote") &&
              subject.user == "fwupd-refresh") {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };
}
