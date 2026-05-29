{ inputs, ... }:
{
  flake.nixosModules.target-x1_12 =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        # https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/x1/12th-gen/default.nix
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen

        (modulesPath + "/hardware/cpu/intel-npu.nix")
        (modulesPath + "/installer/scan/not-detected.nix")

        inputs.disko.nixosModules.disko
        (import ../../disko/_boot-and-ext4.nix { device = "/dev/nvme0n1"; })
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      hardware.cpu.intel.npu.enable = false;
      # Workaround for shutdown/poweroff hang caused by the Intel NPU driver:
      # If the NPU is disabled, blacklist the kernel module to prevent it from loading and hanging the system.
      boot.blacklistedKernelModules = lib.optionals (!config.hardware.cpu.intel.npu.enable) [
        "intel_vpu"
      ];
    };
}
