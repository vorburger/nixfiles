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
          content =
            { config, lib, ... }:
            {
              boot.supportedFilesystems = [ "zfs" ];
              boot.initrd.supportedFilesystems = [ "zfs" ];
              boot.zfs.requestEncryptionCredentials = true;
              systemd.services = {
                zfs-import-cache.serviceConfig.TimeoutStartSec = "90s";
                zfs-import-scan.serviceConfig.TimeoutStartSec = "90s";
              }
              // lib.genAttrs (map (pool: "zfs-import-${pool}") config.boot.zfs.extraPools) (_name: {
                serviceConfig.TimeoutStartSec = "90s";
              });
              services.zfs = {
                autoScrub = {
                  enable = true;
                  interval = "*-*-01 23:00";
                  randomizedDelaySec = "1min";
                };
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
              services.sanoid = {
                enable = true;
                interval = "*:0/15"; # For "frequently" snapshots.
                datasets =
                  lib.genAttrs
                    (map (fs: fs.device) (lib.filter (fs: fs.fsType == "zfs") (lib.attrValues config.fileSystems)))
                    (name: {
                      useTemplate = if name == "bardioc/public" then [ "short" ] else [ "default" ];
                      recursive = true;
                    });
                templates = {
                  "default" = {
                    frequently = 8; # Keep this many snapshots @15min frequency.
                    hourly = 48;
                    daily = 90;
                    weekly = 30;
                    monthly = 24;
                    yearly = 100;
                  };
                  "short" = {
                    frequently = 8;
                    hourly = 48;
                    daily = 90;
                    weekly = 12; # 12 weeks = ~3 months
                    monthly = 3; # 3 months
                    yearly = 0; # no yearly snapshots
                  };
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
