{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.disko.nixosModules.disko
      ../disko/_boot-and-ext4.nix
      ../services/_networking.nix
      ../services/_openssh.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      {
        # This isn't really used... (but required to make `nix flake check` happy)
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/vda" ];

        networking.hostName = "test1";
        system.stateVersion = "25.05";
      }
    ];
  };
}
