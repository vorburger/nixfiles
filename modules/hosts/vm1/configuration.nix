{ inputs, self, ... }:
{
  flake.nixosModules.vm1 = {
    imports = [
      ../_common.nix
      ../../services/_gnome.nix
      ../../services/_virt-guest.nix
      ./_hardware-configuration.nix
      inputs.disko.nixosModules.disko
      (import ../../disko/_boot-and-ext4.nix { device = "/dev/vda"; })
      ../../users/_vorburger.nix
      self.nixosModules.ui
      (_: {
        networking.hostName = "vm1";

        boot.loader.grub.enable = true;
        # NOT boot.loader.grub.device = "/dev/vda"; # NOT vda1, which is the ESP!
        # boot.loader.grub.useOSProber = true;

        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        # programs.mtr.enable = true;
        # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };

        services.virt-guest.enable = true;

        system.stateVersion = "26.05";
      })
    ];
  };

  flake.nixosConfigurations.vm1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ self.nixosModules.vm1 ];
  };

  imports = [
    (import ../../tools/_mk-test.nix { inherit inputs self; } "vm1-boot" self.nixosModules.vm1 ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("lsmod | grep virtio_gpu")
      machine.succeed("kitty --version")
      machine.succeed("brave --version")
    '')
  ];
}
