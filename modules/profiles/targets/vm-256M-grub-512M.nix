{ inputs, lib, ... }:
{
  flake.nixosModules.target-vm-256M-grub-512M =
    { ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
        (import ../../disko/_boot-and-ext4.nix { device = "/dev/vda"; })
      ];

      # Smaller ESP to fit in 256M disk (though 256M is still very tight for NixOS)
      disko.devices.disk.my-disk.content.partitions.ESP.size = lib.mkForce "64M";

      services.virt-guest = {
        enable = true;
        memorySize = 512;
        cores = 1;
      };

      boot.loader.grub.enable = true;
      boot.kernelParams = [ "console=ttyS0" ];

      services.getty.autologinUser = "vorburger";
      services.displayManager.autoLogin = {
        enable = true;
        user = "vorburger";
      };
    };
}
