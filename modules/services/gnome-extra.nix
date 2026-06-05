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
