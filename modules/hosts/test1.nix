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
  name = "test1";
  diskoDevice = "/dev/vda";
  modules = [
    ../users/_tester.nix
    {
      system.stateVersion = "25.05";

      # Help is available on https://nixos.org/nixos/options.html and in the configuration.nix(5) man page.
      boot.loader.grub.enable = true;
      boot.kernelParams = [ "console=ttyS0" ];

      services.virt-guest.enable = true;
    }
  ];
}
