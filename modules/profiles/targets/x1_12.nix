{ inputs, ... }:
{
  flake.nixosModules.target-x1_12 =
    { ... }:
    {
      imports = [
        # https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/x1/12th-gen/default.nix
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
        ../hardware/_x1_12.nix

        inputs.disko.nixosModules.disko
        (import ../../disko/_boot-and-ext4.nix { device = "/dev/nvme0n1"; })
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Workaround for shutdown/poweroff hang caused by the Intel NPU driver
      boot.blacklistedKernelModules = [ "intel_vpu" ];
    };
}
