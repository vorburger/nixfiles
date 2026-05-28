{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.fprintd-extra = mkService {
    name = "fprintd-extra";
    description = "extra fprintd configuration";
    content = {
      services.fprintd.enable = true;
      # Remember to enroll fingerprints with `fprintd-enroll` (for each user).
      security.pam.services.login.fprintAuth = lib.mkDefault true;
      security.pam.services.sudo.fprintAuth = true;
    };
  };
}
