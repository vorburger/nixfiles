{
  flake.nixosModules.nix-extra =
    { config, lib, ... }:
    let
      cfg = config.services.nix-extra;
    in
    {
      options.services.nix-extra = {
        enable = lib.mkEnableOption "extra Nix configuration (flakes, etc.)";
      };

      config = lib.mkIf cfg.enable {
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };
}
