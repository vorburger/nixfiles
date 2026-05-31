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
  name = "ixo-vm";
  diskoDevice = "/dev/vda";
  modules = [
    self.nixosModules.target-vm-1G-grub-8G
    self.nixosModules.personality-workstation
    self.nixosModules.personality-gnome
  ];
}
