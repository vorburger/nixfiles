{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-host.nix { inherit inputs self lib; }) mkHost;
in
mkHost {
  name = "vinea";
  diskoDevice = "/dev/nvme0n1";
  diskoModule = ../disko/_boot-and-ext4.nix;
  modules = [
    self.nixosModules.target-nuc
    self.nixosModules.personality-workstation
    (_: {
      services.zfs-extra.enable = true;
      networking.hostId = "56417937";
    })
  ];
}
