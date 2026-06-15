let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.gnome-extra = mkService {
    name = "gnome-extra";
    description = "extra GNOME configuration";
    content =
      { pkgs, ... }:
      let
        zenity-ssh-askpass = pkgs.writeShellScriptBin "zenity-ssh-askpass" ''
          PROMPT="''${1:-SSH prompt}"

          # Detect if the physically active Virtual Terminal (VT) matches a graphical session's VT
          ACTIVE_TTY=$(cat /sys/class/tty/tty0/active 2>/dev/null || echo "none")
          GRAPHICAL_TTYS=$(loginctl list-sessions --no-legend | sed -e 's/^[[:space:]]*//' | cut -d' ' -f1 | xargs -I {} loginctl show-session {} -p Type -p TTY 2>/dev/null | grep -B1 -E 'Type=(wayland|x11)' | grep 'TTY=' | cut -d= -f2)

          IS_GRAPHICAL=false
          for gtty in $GRAPHICAL_TTYS; do
            if [ "$ACTIVE_TTY" = "$gtty" ]; then
              IS_GRAPHICAL=true
              break
            fi
          done

          if [ "$IS_GRAPHICAL" = "true" ] && { [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; }; then
            if echo "$PROMPT" | grep -iqE "passphrase|password|pin"; then
              exec ${pkgs.zenity}/bin/zenity --password --title="SSH Authentication" --prompt="$PROMPT"
            elif echo "$PROMPT" | grep -iqE "yes/no"; then
              if ${pkgs.zenity}/bin/zenity --question --title="SSH Confirmation" --text="$PROMPT" --ok-label="Allow" --cancel-label="Deny"; then
                echo "yes"
              else
                echo "no"
                exit 1
              fi
            else
              exec ${pkgs.zenity}/bin/zenity --entry --title="SSH" --text="$PROMPT"
            fi
          else
            # Console fallback using systemd-ask-password with a timeout to prevent hanging
            if echo "$PROMPT" | grep -iqE "yes/no"; then
              RESPONSE=$(${pkgs.systemd}/bin/systemd-ask-password --timeout=5 "$PROMPT (type 'yes' or 'y' to confirm): ")
              if echo "$RESPONSE" | grep -iqE "^(yes|y)$"; then
                echo "yes"
              else
                echo "no"
                exit 1
              fi
            else
              exec ${pkgs.systemd}/bin/systemd-ask-password --timeout=5 "$PROMPT: "
            fi
          fi
        '';
      in
      {
        programs.ssh = {
          enableAskPassword = true;
          askPassword = pkgs.lib.mkForce "/run/current-system/sw/bin/zenity-ssh-askpass";
        };

        programs.gnupg.agent = {
          pinentryPackage = pkgs.lib.mkForce pkgs.pinentry-gnome3;
        };

        environment.sessionVariables = {
          SSH_ASKPASS_REQUIRE = "prefer";
        };

        services = {
          displayManager.gdm.enable = true;
          desktopManager.gnome.enable = true;

          gnome.localsearch.enable = false;
          gnome.tinysparql.enable = false;

          desktopManager.gnome.extraGSettingsOverrides = ''
            [org.gnome.desktop.interface]
            color-scheme='prefer-dark'

            [org.gnome.desktop.wm.keybindings]
            switch-applications=[]
            switch-applications-backward=[]
            switch-windows=['<Alt>Tab']
            switch-windows-backward=['<Shift><Alt>Tab']

            [org.gnome.shell.window-switcher]
            current-workspace-only=false

            [org.gnome.shell]
            always-show-log-out=true

            [org.gnome.settings-daemon.plugins.color]
            night-light-enabled=true

            [org.gnome.settings-daemon.plugins.power]
            sleep-inactive-ac-type='nothing'
            sleep-inactive-battery-type='suspend'
            sleep-inactive-battery-timeout=900
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
          gnome-calendar # Calendar
        ];

        environment.systemPackages = with pkgs; [
          zenity-ssh-askpass
          file-roller
          gnome-boxes
        ];

        virtualisation.libvirtd.enable = true;

        users.users.vorburger.extraGroups = [ "libvirtd" ];
      };
  };
}
