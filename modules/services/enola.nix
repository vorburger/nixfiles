let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  inherit (import ../../lib/mk-service.nix) mkService;
  secret = mkSecret {
    name = "enola-github-token";
    moduleName = "enola";
    mode = "0400";
    owner = "enola-builder";
    group = "enola-builder";
  };
in
{ lib, ... }:
lib.recursiveUpdate secret {
  flake.nixosModules.enola = mkService {
    name = "enola";
    description = "Enola Java server service";
    extraOptions =
      { lib, pkgs, ... }:
      {
        port = lib.mkOption {
          type = lib.types.port;
          default = 2609;
          description = "Port on which the Enola server will listen.";
        };
        jarPath = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/enola/server/enola.jar";
          description = "Absolute path to the deployed enola.jar fat JAR file.";
        };
        uiDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/enola/ui";
          description = "Absolute path to the deployed frontend UI assets directory.";
        };
        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/enola/data";
          description = "Working directory and data directory for the Enola server.";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.openjdk25_headless;
          defaultText = lib.literalExpression "pkgs.openjdk25_headless";
          description = "Java package used to execute the Enola JAR.";
        };
        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra arguments to pass to the java -jar command after server and port.";
        };
        builder = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to enable the scheduled automated enola-builder systemd service and timer.";
          };
          calendar = lib.mkOption {
            type = lib.types.str;
            default = "hourly";
            description = "systemd timer OnCalendar schedule for the builder.";
          };
        };
      };
    content =
      {
        cfg,
        lib,
        pkgs,
        ...
      }:
      let
        builderScript = pkgs.writeShellApplication {
          name = "enola-builder-run";
          runtimeInputs = with pkgs; [
            bash
            git
            coreutils
            nix
            direnv
            rsync
            systemd
            cfg.package
          ];
          text = ''
            set -euo pipefail
            # Do *NOT* -x yet, to prevent token from landing in journal!

            # Authenticate git with GitHub token secret without requiring interactive YubiKey
            if [ -f /run/secrets/enola-github-token ]; then
              TOKEN=$(tr -d '\n\r ' </run/secrets/enola-github-token)
              export GH_TOKEN="$TOKEN"
              export GITHUB_TOKEN="$TOKEN"
              git config --global url."https://x-access-token:''${TOKEN}@github.com/".insteadOf "https://github.com/"
            fi

            set -x
            WORK_DIR="/var/lib/enola-builder"
            cd "$WORK_DIR"

            if [ ! -d "enola2" ]; then
              git clone https://github.com/enola-dev/enola2.git enola2
            fi
            if [ ! -d "enola2ui" ]; then
              git clone https://github.com/enola-dev/enola2ui.git enola2ui
            fi

            cd "$WORK_DIR/enola2"
            git fetch origin
            git checkout main
            git pull --ff-only origin main
            direnv allow .

            cd "$WORK_DIR/enola2ui"
            git fetch origin
            git checkout main
            git pull --ff-only origin main
            direnv allow .

            cd "$WORK_DIR/enola2"
            ./scripts/deploy
          '';
        };
      in
      {
        age.secrets = lib.mkIf cfg.builder.enable secret.flake.nixosModules.enola.age.secrets;

        users.users.enola = {
          isSystemUser = true;
          group = "enola";
          home = "/var/lib/enola";
          description = "Enola service daemon user";
        };
        users.groups.enola = { };

        users.users.enola-builder = {
          isSystemUser = true;
          group = "enola-builder";
          extraGroups = [ "enola" ];
          home = "/var/lib/enola-builder";
          createHome = true;
          description = "Enola builder and deployment daemon user";
        };
        users.groups.enola-builder = { };

        security.polkit.enable = true;
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.systemd1.manage-units" &&
                action.lookup("unit") == "enola.service" &&
                (subject.user == "enola-builder" || subject.user == "vorburger")) {
              return polkit.Result.YES;
            }
          });
        '';

        systemd.tmpfiles.rules = [
          "d /var/lib/enola 0755 enola enola -"
          "d /var/lib/enola/server 0775 enola-builder enola -"
          "d ${cfg.uiDir} 0775 enola-builder enola -"
          "d ${cfg.dataDir} 0700 enola enola -"
          "d /var/lib/enola-builder 0700 enola-builder enola-builder -"
        ];

        systemd.services.enola = {
          description = "Enola Java Server";
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "simple";
            User = "enola";
            Group = "enola";
            WorkingDirectory = cfg.dataDir;
            ExecStart = "${cfg.package}/bin/java -jar ${cfg.jarPath} server ${toString cfg.port} ${lib.escapeShellArgs cfg.extraArgs}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };

        systemd.services.enola-builder = lib.mkIf cfg.builder.enable {
          description = "Enola Automated Build and Deployment";
          after = [
            "network.target"
            "agenix.service"
          ];
          path = with pkgs; [
            bash
            coreutils
            git
            nix
            direnv
            rsync
            systemd
            cfg.package
          ];
          serviceConfig = {
            Type = "oneshot";
            User = "enola-builder";
            Group = "enola-builder";
            WorkingDirectory = "/var/lib/enola-builder";
            ExecStart = "${builderScript}/bin/enola-builder-run";
            ExecStartPost = "+${pkgs.systemd}/bin/systemctl try-restart enola.service";
          };
        };

        systemd.timers.enola-builder = lib.mkIf cfg.builder.enable {
          description = "Periodic Enola Build and Deployment Timer";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.builder.calendar;
            Persistent = true;
          };
        };
      };
  };
}
