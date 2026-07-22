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
      };
  };
}
