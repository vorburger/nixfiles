{ inputs, ... }:
{
  flake.nixosModules.target-x1_12 =
    { ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
        (import ../../disko/_boot-and-ext4.nix { device = "/dev/nvme0n1"; })
        ../hardware/_x1_12.nix
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    };
}
