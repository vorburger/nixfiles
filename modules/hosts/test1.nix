{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Disko isn't really used... TODO Figure out how to remove this...
      inputs.disko.nixosModules.disko
      (import ../disko/_boot-and-ext4.nix { device = "/dev/vda"; })

      ../services/_networking.nix
      ../services/_openssh.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      {
        networking.hostName = "test1";
        system.stateVersion = "25.05";

        # This isn't really used...
        # but it's currently required to make `nix flake check` happy;
        # TODO Figure out how to remove this...
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/vda1" ]; # vda1 or vda?
      }
    ];
  };
}
