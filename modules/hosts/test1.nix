{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      ../disko/_boot-and-ext4.nix
      ../users/_tester.nix
      ../users/_vorburger.nix
      (_: {
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

        # TODO Verify if hostname is automatically set from flake name / attribute name or not?
        networking.hostName = "test1";

        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "prohibit-password";
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
