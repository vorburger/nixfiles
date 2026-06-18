let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.hyprland-extra = mkService {
    name = "hyprland-extra";
    description = "extra Hyprland configuration";
    content = { pkgs, config, ... }: {
      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      home-manager.users.vorburger = {
        wayland.windowManager.hyprland = {
          enable = true;
          package = null;
          portalPackage = null;
          systemd.enable = false;
          configType = "hyprlang";
          settings = {
            input = {
              kb_layout = "ch";
              kb_variant = "de";
            };
            "$mainMod" = "SUPER";
            bind = [
              "$mainMod, Return, exec, kitty"
              "$mainMod, Q, exec, kitty"
              "$mainMod, T, exec, kitty"
              "$mainMod, D, exec, wofi --show drun"
              "$mainMod, R, exec, wofi --show drun"
              "$mainMod SHIFT, E, exit"
              "$mainMod SHIFT, Q, exit"
              "$mainMod, C, killactive"
              "$mainMod, V, togglefloating"
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"
              # Workspaces
              "$mainMod, 1, workspace, 1"
              "$mainMod, 2, workspace, 2"
              "$mainMod, 3, workspace, 3"
              "$mainMod, 4, workspace, 4"
              "$mainMod, 5, workspace, 5"
              "$mainMod, 6, workspace, 6"
              "$mainMod, 7, workspace, 7"
              "$mainMod, 8, workspace, 8"
              "$mainMod, 9, workspace, 9"
              "$mainMod, 0, workspace, 10"
              # Move active window to workspace
              "$mainMod SHIFT, 1, movetoworkspace, 1"
              "$mainMod SHIFT, 2, movetoworkspace, 2"
              "$mainMod SHIFT, 3, movetoworkspace, 3"
              "$mainMod SHIFT, 4, movetoworkspace, 4"
              "$mainMod SHIFT, 5, movetoworkspace, 5"
              "$mainMod SHIFT, 6, movetoworkspace, 6"
              "$mainMod SHIFT, 7, movetoworkspace, 7"
              "$mainMod SHIFT, 8, movetoworkspace, 8"
              "$mainMod SHIFT, 9, movetoworkspace, 9"
              "$mainMod SHIFT, 0, movetoworkspace, 10"
            ];
          };
          plugins = [
            pkgs.hyprlandPlugins.hyprbars
          ];
        };

        xdg.configFile."uwsm/env".source =
          "${config.home-manager.users.vorburger.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

        home.pointerCursor = {
          gtk.enable = true;
          # x11.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        home.packages = with pkgs; [
          kitty
          wofi
        ];
      };
    };
  };
}
