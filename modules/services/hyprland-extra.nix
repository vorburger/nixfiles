let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.hyprland-extra = mkService {
    name = "hyprland-extra";
    description = "extra Hyprland configuration";
    content = _: {
      programs.hyprland = {
        enable = true;
      };

      home-manager.users.vorburger = {
        wayland.windowManager.hyprland = {
          enable = true;
          configType = "hyprlang";
          settings = {
            input = {
              kb_layout = "ch";
              kb_variant = "de";
            };
          };
        };
      };
    };
  };
}
