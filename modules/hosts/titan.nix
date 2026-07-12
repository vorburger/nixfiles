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
        pkgs,
        ...
      }@args:
      let
        unstable-pkgs = import args.inputs.nixpkgs {
          system = pkgs.stdenv.hostPlatform.system;
          inherit (pkgs) config;
        };
      in
      {
        system.stateVersion = "26.05";
        networking.hostId = "8425e349";

        services.printing-extra.enable = false; # true for CUPS (but generally NOT required); see http://localhost:631
        services.gpg-with-yubikey.ssh = true;
        services.smart.enable = true;
        services.samba-extra.enable = true;
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
          options = [ "nofail" ];
          neededForBoot = false; # set to true if system services depend on this data
        };

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            libva
            libva-vdpau-driver
            libvdpau-va-gl
          ];
        };
        services.ollama = {
          enable = true;
          package = unstable-pkgs.ollama-rocm;
        };
        environment.systemPackages = with unstable-pkgs; [
          nvtopPackages.amd
        ];
      }
    )
  ];
}
