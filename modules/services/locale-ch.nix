{
  flake.nixosModules.locale-ch =
    { config, lib, ... }:
    let
      cfg = config.services.locale-ch;
    in
    {
      options.services.locale-ch = {
        enable = lib.mkEnableOption "Swiss locale and timezone settings";
      };

      config = lib.mkIf cfg.enable {
        time.timeZone = "Europe/Zurich";
        i18n.defaultLocale = "en_GB.UTF-8";

        console.keyMap = "sg";

        services.xserver.xkb = {
          layout = "ch";
          variant = "de";
        };
      };
    };
}
