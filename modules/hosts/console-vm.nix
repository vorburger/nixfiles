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
  diskoDevice = "/dev/vda";
  modules = [
    # Keep tiny VM image bootable by shrinking the ESP for this host's disk layout.
    (
      { lib, config, ... }:
      {
        system.stateVersion = config.system.nixos.release;
        disko.devices.disk.my-disk.content.partitions.ESP.size = lib.mkForce "64M";
      }
    )
    self.nixosModules.target-vm-256M-grub-512M
    self.nixosModules.personality-console
  ];
}
