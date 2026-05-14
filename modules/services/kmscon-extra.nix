let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.kmscon-extra = mkService {
    name = "kmscon-extra";
    description = "extra kmscon configuration";
    content =
      { pkgs, ... }:
      {
        # This is a fallback for very early boot before kmscon starts.
        console = {
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
      };
  };
}
