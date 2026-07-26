let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.pam-u2f = mkService {
    name = "pam-u2f";
    description = "PAM U2F YubiKey integration";
    content =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.pam_u2f ];

        security.pam.u2f = {
          enable = false;
          control = "sufficient";
          settings = {
            cue = true;
          };
        };
        security.pam.services.sudo.u2fAuth = true;
        security.pam.services.polkit-1.u2fAuth = true;
        security.pam.services.systemd-run0.u2fAuth = true;

        # Allow polkit-agent-helper to access FIDO/U2F devices (/dev/hidraw*)
        # and read ~/.config/Yubico/u2f_keys when security.pam.u2f.enable is false.
        systemd.services."polkit-agent-helper@".serviceConfig = {
          PrivateDevices = false;
          DeviceAllow = [
            "/dev/urandom r"
            "char-hidraw rw"
          ];
          ProtectHome = "read-only";
        };
      };
  };
}
