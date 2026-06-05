let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.zfs-extra =
    { ... }:
    {
      imports = [
        (mkService {
          name = "zfs-extra";
          description = "extra ZFS configuration";
          content = {
            boot.supportedFilesystems = [ "zfs" ];
            services.zfs = {
              autoScrub = {
                enable = true;
                interval = "*-*-01 23:00";
                randomizedDelaySec = "1min";
              };
              autoSnapshot.enable = true; # TODO or sanoid?
              trim = {
                enable = true;
                interval = "Fri 22:00";
                randomizedDelaySec = "1min";
              };

              zed.settings = {
                # TODO Enable Mail service...
                ZED_EMAIL_ADDR = [ "root" ];
                ZED_NOTIFY_VERBOSE = true;

                # NAS only: ZED_USE_ENCLOSURE_LEDS = true;
                ZED_SCRUB_AFTER_RESILVER = true;
              };
            };
          };
        })
      ];

      # Always set boot.zfs.forceImportRoot to false to prevent the NixOS warning
      # "boot.zfs.forceImportRoot is not set, which default to true and may cause boot failure"
      # from triggering when this module is imported but not explicitly activated.
      boot.zfs.forceImportRoot = false;
    };
}
