{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          envHOME = "";
        };
        home-manager.users.vorburger = import "${inputs.vorburger-dotfiles}/home.nix";
      }
      ../disko/_boot-and-ext4.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      ../services/_openssh.nix
      (_: {
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

        networking.hostName = "test1";

        # virtualisation.forwardPorts = [
        #   {
        #     from = "host";
        #     host.port = 2222;
        #     guest.port = 22;
        #     # You can optionally specify the protocol (default is "tcp")
        #     # protocol = "tcp";
        #   }
        # ];

        system.stateVersion = "25.05";
      })
    ];
  };
}
