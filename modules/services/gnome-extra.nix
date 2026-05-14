{
  flake.nixosModules.gnome-extra =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.gnome-extra;
    in
    {
      options.services.gnome-extra = {
        enable = lib.mkEnableOption "extra GNOME configuration";
      };

      config = lib.mkIf cfg.enable {
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
