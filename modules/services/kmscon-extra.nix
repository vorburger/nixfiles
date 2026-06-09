let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.kmscon-extra = mkService {
    name = "kmscon-extra";
    description = "extra kmscon configuration";
    content =
      {
        pkgs,
        options,
        lib,
        ...
      }:
      let
        isNewKmscon = options.services.kmscon ? config;
      in
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

        hardware.graphics.enable = lib.mkIf isNewKmscon true;

        fonts.packages = lib.mkIf isNewKmscon [
          pkgs.nerd-fonts.fira-code
        ];

        services.kmscon =
          if isNewKmscon then
            {
              enable = true;
              config = {
                "font-name" = "FiraCode Nerd Font Mono";
                "font-size" = "24";
                "hwaccel" = true;
                "xkb-layout" = "ch";
                "xkb-variant" = "de";
                "grab-scroll-up" = "<Alt>Up";
                "grab-scroll-down" = "<Alt>Down";
                "grab-page-up" = "<Alt>Prior";
                "grab-page-down" = "<Alt>Next";
              };
            }
          else
            {
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
                grab-page-up=<Alt>Prior
                grab-page-down=<Alt>Next
              '';
            };
      };
  };
}
