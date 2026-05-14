let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.locale-ch = mkService {
    name = "locale-ch";
    description = "Swiss locale and timezone settings";
    content = {
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
