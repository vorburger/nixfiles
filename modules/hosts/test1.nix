{ inputs, self, ... }:
{
  flake.nixosModules.test1 = {
    imports = [
      ./_common.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      {
        # Help is available on https://nixos.org/nixos/options.html and in the configuration.nix(5) man page.
        networking.hostName = "test1";
        system.stateVersion = "25.05";

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

        # This is currently required just to make `nix flake check` happy
        # (even though this test1 VM doesn't actually use a bootloader)
        boot.loader.grub.devices = [ "/dev/vda" ];

        boot.kernelParams = [ "console=ttyS0" ];

        services.virt-guest.enable = true;
      }
    ];
  };

  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ self.nixosModules.test1 ];
  };

  imports = [
    (import ../tools/_mk-test.nix { inherit inputs self; } "test1-boot" self.nixosModules.test1 null)
  ];
}
