{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      ../disko/_boot-and-ext4.nix
      ../services/_networking.nix
      ../services/_openssh.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      {
        # TODO How can this be moved into vorburger.nix ?!
        home-manager.users.vorburger = import "${inputs.vorburger-dotfiles}/home.nix";

        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

        networking.hostName = "test1";
        system.stateVersion = "25.05";
      }
    ];
  };
}
