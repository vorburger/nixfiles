{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.pam-u2f = mkService {
    name = "pam-u2f";
    description = "PAM U2F YubiKey integration";
    extraOptions = {
      requireSeat = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Only trigger PAM U2F authentication when on a physical seat (local console or graphical session), skipping it for remote sessions like SSH.";
      };
    };
    content =
      {
        cfg,
        pkgs,
        ...
      }:
      let
        checkSeat = pkgs.writeShellScript "check-u2f-seat" ''
          # Exit 0 if remote or no seat (skip U2F).
          # Exit 1 if on a physical seat (proceed with U2F).
          if [ -n "$(${pkgs.systemd}/bin/loginctl show-session self -p Seat --value 2>/dev/null)" ]; then
            exit 1
          fi
          exit 0
        '';

        mkSeatCheckRule =
          serviceName:
          lib.mkIf cfg.requireSeat {
            security.pam.services.${serviceName}.rules.auth.u2f-seat-check = {
              order = 10850; # immediately before u2f (order 10900)
              control = "[success=1 default=ignore]";
              modulePath = "${pkgs.linux-pam}/lib/security/pam_exec.so";
              args = [
                "quiet"
                "${checkSeat}"
              ];
            };
          };
      in
      lib.mkMerge (
        [
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
          }
        ]
        ++ (map mkSeatCheckRule [
          "sudo"
          "polkit-1"
          "systemd-run0"
        ])
      );
  };
}
