{ inputs, ... }:
{
  flake.nixosConfigurations.ixo = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };

    modules = [
      ./_hardware-configuration.nix
      inputs.disko.nixosModules.disko
      (import ../../disko/_boot-and-ext4.nix { device = "/dev/nvme0n1"; })
      ../../services/_networking.nix
      ../../services/_openssh.nix
      ../../users/_vorburger.nix
      {
        # Help is available on https://nixos.org/nixos/options.html and in the configuration.nix(5) man page.
        networking.hostName = "ixo";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # TODO Factor all of this out into an _local.nix, and re-use it...
        time.timeZone = "Europe/Zurich";
        i18n.defaultLocale = "en_GB.UTF-8";
        services.xserver.xkb = {
          layout = "ch";
          variant = "";
        };
        console.keyMap = "sg";

        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        # programs.mtr.enable = true;
        # programs.gnupg.agent = {
        #   enable = true;
        #   enableSSHSupport = true;
        # };

        system.stateVersion = "26.05";
      }
    ];
  };
}
