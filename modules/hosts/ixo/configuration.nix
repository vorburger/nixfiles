{ inputs, self, ... }:
{
  flake.nixosModules.ixo = {
    imports = [
      ../_common.nix
      ./_hardware-configuration.nix
      inputs.disko.nixosModules.disko
      (import ../../disko/_boot-and-ext4.nix { device = "/dev/nvme0n1"; })
      ../../users/_vorburger.nix
      (
        { pkgs, ... }:
        {
          networking.hostName = "ixo";
          system.stateVersion = "26.05";

          environment.systemPackages = [
            pkgs.starship
            pkgs.pulseaudio # Provides `paplay` for audio alerts
          ];

          services.initial-secrets.enable = true;
          services.gpg-with-yubikey.enable = true;
          services.ssh-tpm-agent.enable = true;
          services.ssh-agent-mux.enable = true;
          services.pipewire-extra.enable = true;

          services.fprintd.enable = true;
          # Remember to enroll fingerprints with `fprintd-enroll` (for each user).
          security.pam.services.login.fprintAuth = true;
          security.pam.services.sudo.fprintAuth = true;

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          console = {
            # This is a fallback for very early boot before kmscon starts.
            font = "ter-v24n";
            packages = [
              pkgs.kbd
              pkgs.terminus_font
            ];
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
        }
      )
    ];
  };

  flake.nixosConfigurations.ixo = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ self.nixosModules.ixo ];
  };

  imports = [
    (import ../../tools/_mk-test.nix { inherit inputs self; } "ixo-boot" self.nixosModules.ixo null)
  ];
}
