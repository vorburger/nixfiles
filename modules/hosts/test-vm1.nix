{ inputs, ... }:
{
  flake.nixosConfigurations.test-vm1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # TODO Modularize this further...
      inputs.disko.nixosModules.disko
      ./disko/_boot-and-ext4.nix
      {
        networking.hostName = "test-vm1";
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "prohibit-password";
        users.users.test = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };

        boot.loader.grub.enable = true;
        boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device
      }
    ];
  };
}
