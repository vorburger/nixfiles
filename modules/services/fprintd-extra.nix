{
  flake.nixosModules.fprintd-extra =
    { config, lib, ... }:
    let
      cfg = config.services.fprintd-extra;
    in
    {
      options.services.fprintd-extra = {
        enable = lib.mkEnableOption "extra fprintd configuration";
      };

      config = lib.mkIf cfg.enable {
        services.fprintd.enable = true;
        # Remember to enroll fingerprints with `fprintd-enroll` (for each user).
        security.pam.services.login.fprintAuth = true;
        security.pam.services.sudo.fprintAuth = true;
      };
    };
}
