{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (import ../../../lib/mk-host.nix { inherit inputs self lib; }) mkHost;
in
mkHost {
  name = "gnome-grub";
  diskoDevice = "/dev/vda";
  modules = [
    ./_hardware-configuration.nix
    self.nixosModules.ui
    {
      system.stateVersion = "26.05";
      boot.loader.grub.enable = true;

      services.virt-guest.enable = true;
      services.gnome-extra.enable = true;
    }
  ];
  testScript = ''
    machine.succeed("lsmod | grep virtio_gpu")
    machine.succeed("kitty --version")
    machine.succeed("brave --version")
  '';
}
