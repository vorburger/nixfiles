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
  name = "gnome-vm";
  modules = [
    self.nixosModules.target-vm-1G-grub-8G
    self.nixosModules.personality-gnome
  ];
  testScript = ''
    machine.succeed("lsmod | grep virtio_gpu")
    machine.succeed("kitty --version")
    machine.succeed("brave --version")
  '';
}
