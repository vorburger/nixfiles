{
  flake.nixosModules.zfs = {
    boot.zfs.forceImportRoot = false;
  };
}
