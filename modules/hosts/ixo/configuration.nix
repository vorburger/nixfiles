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
      ../../services/_gpg-with-yubikey.nix
      ../../services/_pipewire.nix
      ../../users/_vorburger.nix
      (
        { pkgs, ... }:
        {
          # Help is available on https://nixos.org/nixos/options.html and in the configuration.nix(5) man page.
          networking.hostName = "ixo";

          environment.systemPackages = [
            pkgs.starship
            pkgs.pulseaudio # Provides `paplay` for audio alerts
          ];

          services.initial-secrets.enable = true;

          services.fprintd.enable = true;
          # Remember to enroll fingerprints with `fprintd-enroll` (for each user).
          security.pam.services.login.fprintAuth = true;
          security.pam.services.sudo.fprintAuth = true;

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
            # This is a fallback for very early boot before kmscon starts.
            font = "ter-v24n";
            packages = [
              pkgs.kbd
              pkgs.terminus_font
            ];
            # TODO Centralize this in the same place as the xserver.xkb and kmscon
            keyMap = "sg";
          };

          services.getty.loginProgram = "/run/current-system/sw/bin/login";
          systemd.tmpfiles.rules = [
            "d /bin 0755 root root -"
            "L+ /bin/login - - - - /run/current-system/sw/bin/login"
          ];

          # Ensure the kmscon service can see the wrappers
          systemd.services."kmscon@".path = [ "/run/wrappers" ];

          services.kmscon = {
            enable = true;
            hwRender = true;
            fonts = [
              {
                name = "FiraCode Nerd Font Mono";
                package = pkgs.nerd-fonts.fira-code;
              }
            ];
            extraConfig = ''
              font-size=24
              xkb-layout=ch
              xkb-variant=de
              grab-scroll-up=<Alt>Up
              grab-scroll-down=<Alt>Down
              grab-page-up=<Alt>PageUp
              grab-page-down=<Alt>PageDown
            '';
          };

          # Some programs need SUID wrappers, can be configured further or are
          # started in user sessions.
          # programs.mtr.enable = true;

          system.stateVersion = "26.05";
        }
      )
    ];
  };
}
