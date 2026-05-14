{ inputs, self, ... }:
{
  flake.nixosModules.test1 = {
    imports = [
      # Disko isn't really used...
      # inputs.disko.nixosModules.disko
      # (import ../disko/_boot-and-ext4.nix { device = "/dev/vda"; })

      ./_common.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      {
        networking.hostName = "test1";
        system.stateVersion = "25.05";

        boot.kernelParams = [ "console=ttyS0" ];

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

        # This is currently required to make `nix flake check` happy
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/vda" ];
      }
    ];
  };

  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ self.nixosModules.test1 ];
  };

  imports = [
    (import ../tools/_mk-test.nix { inherit inputs self; } "test1-boot" self.nixosModules.test1)
  ];
}
