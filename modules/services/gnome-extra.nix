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
        programs.ssh = {
          enableAskPassword = true;
          askPassword = pkgs.lib.mkForce "${pkgs.writeShellScript "zenity-ssh-askpass" ''
            PROMPT="''${1:-SSH prompt}"
            if echo "$PROMPT" | grep -iqE "passphrase|password|pin"; then
              exec ${pkgs.zenity}/bin/zenity --password --title="SSH Authentication" --prompt="$PROMPT"
            else
              exec ${pkgs.zenity}/bin/zenity --question --title="SSH Confirmation" --text="$PROMPT" --ok-label="Allow" --cancel-label="Deny"
            fi
          ''}";
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
          file-roller
          gnome-boxes
        ];

        virtualisation.libvirtd.enable = true;

        users.users.vorburger.extraGroups = [ "libvirtd" ];
      };
  };
}
