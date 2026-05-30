{ inputs, ... }:
{
  flake.nixosModules.target-nuc =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        inputs.nixos-hardware.nixosModules.intel-nuc-8i7beh
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
