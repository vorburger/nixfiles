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
    extraOptions = {
      maxTries = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Allowed attempts for fingerprint authentication in PAM before falling back to password.";
      };
    };
    content =
      { cfg, ... }:
      {
        services.fprintd.enable = true;
        # Remember to enroll fingerprints with `fprintd-enroll` (for each user).
        security.pam.services.login.fprintAuth = lib.mkDefault true;
        security.pam.services.sudo.fprintAuth = true;

        security.pam.services.sudo.rules.auth.fprintd.settings.max-tries = cfg.maxTries;
        security.pam.services.gdm-fingerprint.rules.auth.fprintd.settings.max-tries = cfg.maxTries;
        security.pam.services.login.rules.auth.fprintd.settings.max-tries = cfg.maxTries;
        security.pam.services.polkit-1.rules.auth.fprintd.settings.max-tries = cfg.maxTries;
      };
  };
}
