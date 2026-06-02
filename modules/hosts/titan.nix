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
  name = "titan";
  nixpkgs = inputs.nixpkgs-stable;
  diskoDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZVKW512HMJP-000L7_S35BNX0K809192";
  modules = [
    self.nixosModules.personality-workstation
    self.nixosModules.personality-gnome
    (_: {
      services.zfs-extra.enable = true;
      networking.hostId = "8425e349";

      hardware.amdgpu.initrd.enable = true; # sets boot.initrd.kernelModules = ["amdgpu"];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "rtsx_usb_sdmmc"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      boot.loader.grub.enable = false;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Dummy file systems because HW target is TBD
      fileSystems."/" = {
        fsType = "ext4";
      };
    })
  ];
}
