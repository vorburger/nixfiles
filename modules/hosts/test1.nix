{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # TODO Modularize this...
      inputs.disko.nixosModules.disko
      ./disko/_boot-and-ext4.nix
      {
        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

        # TODO Verify if hostname is automatically set from flake name / attribute name or not?
        networking.hostName = "test1";

        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "prohibit-password";

        users.users.test = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          initialPassword = "x";
        };

        system.stateVersion = "25.05";
      }
    ];
  };
}
