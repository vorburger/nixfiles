let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.gnome-extra = mkService {
    name = "gnome-extra";
    description = "extra GNOME configuration";
    content =
      { pkgs, ... }:
      {
        services = {
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;

          gnome.core-apps.enable = false;
          gnome.localsearch.enable = false;
          gnome.tinysparql.enable = false;

          desktopManager.gnome.extraGSettingsOverrides = ''
            [org.gnome.desktop.interface]
            color-scheme='prefer-dark'
          '';
        };

        environment.gnome.excludePackages = with pkgs; [
          gnome-tour
        ];
      };
  };
}
