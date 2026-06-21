{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.power = mkService {
    name = "power";
    description = "power management tuning and profile switching";
    content =
      { pkgs, ... }:
      let
        power-profile-script = pkgs.writeShellScriptBin "power-profile-switcher" ''
          # Find if AC is online
          ac_online=0
          for db in /sys/class/power_supply/*; do
            if [ -f "$db/online" ] && [ "$(cat "$db/online")" -eq 1 ]; then
              ac_online=1
              break
            fi
          done

          if [ "$ac_online" -eq 1 ]; then
            echo "AC is online, setting profile to performance"
            ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
          else
            # Find battery capacity
            capacity=100
            for bat in /sys/class/power_supply/BAT*; do
              if [ -f "$bat/capacity" ]; then
                capacity=$(cat "$bat/capacity")
                break
              fi
            done
            
            echo "AC is offline, battery capacity is $capacity%"
            if [ "$capacity" -lt 40 ]; then
              echo "Setting profile to power-saver"
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
            else
              echo "Setting profile to balanced"
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
            fi
          fi
        '';
      in
      {
        powerManagement.powertop.enable = true;
        services.power-profiles-daemon.enable = lib.mkDefault true;

        # TODO Huh, why is this not automagic, with: powerManagement.powertop.enable
        environment.systemPackages = [ pkgs.powertop ];

        services.udev.extraRules = ''
          SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-switcher.service"
        '';

        systemd.services.disable-wakeup-triggers = {
          description = "Disable sleep wakeup triggers for USB (XHCI) and Thunderbolt (TXHC)";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "disable-wakeups" ''
              # Toggle off wakeup for XHCI and TXHC if they are currently enabled
              for device in XHCI TXHC; do
                if ${pkgs.gnugrep}/bin/grep -q "$device.*\*enabled" /proc/acpi/wakeup; then
                  echo "$device" > /proc/acpi/wakeup
                fi
              done
            '';
            RemainAfterExit = true;
          };
        };

        systemd.services.power-profile-switcher = {
          description = "Switch power profiles based on power source and battery level";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${power-profile-script}/bin/power-profile-switcher";
          };
        };

        systemd.timers.power-profile-switcher = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "1m";
            OnUnitActiveSec = "5m";
          };
        };
      };
  };
}
