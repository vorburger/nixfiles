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

          gnome.localsearch.enable = false;
          gnome.tinysparql.enable = false;

          desktopManager.gnome.extraGSettingsOverrides = ''
            [org.gnome.desktop.interface]
            color-scheme='prefer-dark'
          '';
        };

        environment.gnome.excludePackages = with pkgs; [
          gnome-tour # Welcome tour wizard
          gnome-connections # Remote desktop client
          epiphany # GNOME Web Browser
          geary # GNOME Email client
          gnome-maps # Maps
          gnome-weather # Weather
          gnome-contacts # Contacts
          gnome-music # Music player
        ];
      };
  };
}
