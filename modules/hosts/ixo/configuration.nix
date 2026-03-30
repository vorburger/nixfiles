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
      ../../services/_nix.nix
      ../../services/_initial-secrets.nix
      ../../users/_vorburger.nix
      (
        { pkgs, ... }:
        {
          # Help is available on https://nixos.org/nixos/options.html and in the configuration.nix(5) man page.
          networking.hostName = "ixo";

          services.initial-secrets.enable = true;

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # TODO Factor all of this out into an _local.nix, and re-use it...
          time.timeZone = "Europe/Zurich";
          i18n.defaultLocale = "en_GB.UTF-8";
          services.xserver.xkb = {
            # TODO Avoid repetition with similar in kmscon
            layout = "ch";
            variant = "de";
          };

          console = {
            font = "sun12x22";
            packages = [ pkgs.kbd ];
            # TODO Centralize this in the same place as the xserver.xkb and kmscon
            keyMap = "sg";
          };

          services.kmscon = {
            enable = true;
            hwRender = true;
            fonts = [
              {
                name = "FiraCode Nerd Font Mono";
                package = pkgs.nerd-fonts.fira-code;
              }
            ];
            # TODO Avoid repetition with similar in services.xserver.xkb
            extraOptions = "--font-size=24 --xkb-layout=ch --xkb-variant=de";
          };

          # Some programs need SUID wrappers, can be configured further or are
          # started in user sessions.
          # programs.mtr.enable = true;
          # programs.gnupg.agent = {
          #   enable = true;
          #   enableSSHSupport = true;
          # };

          system.stateVersion = "26.05";
        }
      )
    ];
  };
}
