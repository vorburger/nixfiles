{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
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
