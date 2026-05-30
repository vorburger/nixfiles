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
  name = "ixo";
  diskoDevice = "/dev/nvme0n1";
  modules = [
    self.nixosModules.target-x1_12
    self.nixosModules.personality-workstation
    self.nixosModules.personality-gnome
  ];
}
