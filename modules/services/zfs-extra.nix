{
  flake.nixosModules.zfs-extra = {
    boot.zfs.forceImportRoot = false;
  };
}
