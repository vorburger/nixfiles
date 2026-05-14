let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.zfs-extra = mkService {
    name = "zfs-extra";
    description = "extra ZFS configuration";
    content = {
      boot.zfs.forceImportRoot = false;
    };
  };
}
