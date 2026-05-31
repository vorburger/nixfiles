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
            services.zfs.autoScrub.enable = true;
            services.zfs.trim.enable = true;
          };
        })
      ];

      # Always set boot.zfs.forceImportRoot to false to prevent the NixOS warning
      # "boot.zfs.forceImportRoot is not set, which default to true and may cause boot failure"
      # from triggering when this module is imported but not explicitly activated.
      boot.zfs.forceImportRoot = false;
    };
}
