{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      ../disko/_boot-and-ext4.nix
      ../users/_tester.nix
      ../services/_openssh.nix
      ../users/_vorburger.nix
      {
        # TODO How can this be moved into vorburger.nix ?!
        home-manager.users.vorburger = import "${inputs.vorburger-dotfiles}/home.nix";

        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

        networking.hostName = "test1";
        networking.networkmanager.enable = true;
        systemd.services.NetworkManager-wait-online.enable = true;

        virtualisation.vmVariant = {
          virtualisation.forwardPorts = [
            {
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }
          ];
        };

        system.stateVersion = "25.05";
      }
    ];
  };
}
