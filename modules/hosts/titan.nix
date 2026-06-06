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
    (
      {
        vmTest ? false,
        ...
      }:
      {
        system.stateVersion = "26.05";
        networking.hostId = "8425e349";

        services.gpg-with-yubikey.ssh = true;
        services.smart.enable = true;
        services.zfs-extra.enable = true;
        services.zram.enable = true;
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
        fileSystems."/" = {
          fsType = "ext4";
        };
        # pool8 only exists on the physical bare metal machine, not in VM tests
        boot.zfs.extraPools = lib.mkIf (!vmTest) [ "pool8" ];
        fileSystems."/nas" = lib.mkIf (!vmTest) {
          device = "pool8/nas";
          fsType = "zfs";
          neededForBoot = false; # set to true if system services depend on this data
        };
      }
    )
  ];
}
