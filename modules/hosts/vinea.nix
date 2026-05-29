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
  modules = [
    self.nixosModules.target-nuc
    self.nixosModules.personality-workstation
  ];
}
