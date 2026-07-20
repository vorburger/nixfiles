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
        # ZFS pool only exists on the physical bare metal machine, not in VM tests
        boot.zfs.extraPools = lib.mkIf (!vmTest) [ "bardioc" ];
        fileSystems."/bardioc/private" = lib.mkIf (!vmTest) {
          device = "bardioc/private";
          fsType = "zfs";
          options = [ "nofail" ];
          neededForBoot = false; # set to true if system services depend on this data
        };
        fileSystems."/bardioc/public" = lib.mkIf (!vmTest) {
          device = "bardioc/public";
          fsType = "zfs";
          options = [ "nofail" ];
          neededForBoot = false;
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

        # https://jellyfin.org
        services.jellyfin = {
          enable = true;
          openFirewall = true;
          hardwareAcceleration = {
            enable = true;
            type = "vaapi";
            device = "/dev/dri/renderD128";
          };
          transcoding = {
            enableHardwareEncoding = true;
            hardwareDecodingCodecs = {
              h264 = true;
              hevc = true;
              hevc10bit = true;
              vp9 = true;
              av1 = true;
              mpeg2 = true;
              vc1 = true;
            };
            hardwareEncodingCodecs = {
              hevc = true;
              av1 = true;
            };
          };
        };
        users.users.jellyfin.extraGroups = [
          "video"
          "render"
        ];
        systemd.services.jellyfin.serviceConfig.PrivateUsers = lib.mkForce false;

        services.backup = {
          enable = true;
          baseDir = "/bardioc/services";
          zfs = {
            enable = !vmTest;
            pool = "bardioc";
          };
          jobs.jellyfin = {
            srcDir = "/var/lib/jellyfin";
            sqliteDbs = [
              "data/jellyfin.db"
            ];
          };
        };
      }
    )
  ];
}
