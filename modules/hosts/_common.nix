{ self, ... }:
{
  imports = [
    self.nixosModules.zfs
    ../services/_ch.nix
    ../services/_networking.nix
    ../services/_openssh.nix
    ../services/_nix.nix
  ];
}
