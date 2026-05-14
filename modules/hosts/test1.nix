{ inputs, self, ... }:
{
  flake.nixosModules.test1 = {
    imports = [
      # Disko isn't really used...
      # inputs.disko.nixosModules.disko
      # (import ../disko/_boot-and-ext4.nix { device = "/dev/vda"; })

      ../services/_networking.nix
      ../services/_openssh.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      {
        networking.hostName = "test1";
        system.stateVersion = "25.05";

        boot.kernelParams = [ "console=ttyS0" ];

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
        };

        # This is currently required to make `nix flake check` happy
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/vda" ];
      }
    ];
  };

  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [ self.nixosModules.test1 ];
  };
}
