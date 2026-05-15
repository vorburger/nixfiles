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
  name = "console-vm";
  modules = [
    self.nixosModules.target-vm-256M-grub-512M
    self.nixosModules.personality-console
  ];
}
