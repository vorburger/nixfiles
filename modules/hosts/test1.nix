{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      {
        # Required to avoid: "Existing file '/home/vorburger/.config/fish/config.fish' would be clobbered"
        home-manager.backupFileExtension = "home-manager_backup";

        systemd.services.home-manager-vorburger = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        # See https://github.com/vorburger/vorburger-dotfiles-bin-etc/blob/main/dotfiles/home-manager/flake.nix
        home-manager.extraSpecialArgs = {
          envHOME = "";
        };
        home-manager.users.vorburger = import "${inputs.vorburger-dotfiles}/home.nix";
      }
      ../disko/_boot-and-ext4.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      ../services/_openssh.nix
      {
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

        networking.hostName = "test1";
        networking.networkmanager.enable = true;
        systemd.services.NetworkManager-wait-online.enable = true;

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
      }
    ];
  };
}
