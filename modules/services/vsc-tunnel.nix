let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.vsc-tunnel = mkService {
    name = "vsc-tunnel";
    description = "Visual Studio Code Remote Tunnel service";
    extraOptions =
      { lib, pkgs, ... }:
      {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.vscode;
          defaultText = lib.literalExpression "pkgs.vscode";
          description = "The VS Code package providing the code executable.";
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "vorburger";
          description = "The user account under which the VS Code tunnel service runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "vorburger";
          description = "The group under which the VS Code tunnel service runs.";
        };

        tunnelName = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Machine name for the port forwarding service. If null, the system hostname is used.";
        };

        acceptServerLicenseTerms = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to accept the VS Code Server license terms automatically.";
        };

        cliDataDir = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Directory where CLI metadata and authentication tokens are stored. If null, defaults to ~/.vscode/cli under user home.";
        };

        serverDataDir = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Directory where server data is kept.";
        };

        extensionsDir = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Directory where extensions are stored.";
        };

        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Optional path to an environment file providing authentication tokens (such as VSCODE_CLI_ACCESS_TOKEN or VSCODE_CLI_REFRESH_TOKEN).";
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra arguments passed to code tunnel.";
        };
      };
    content =
      {
        cfg,
        config,
        lib,
        pkgs,
        ...
      }:
      let
        userHome =
          if config.users.users ? ${cfg.user} && config.users.users.${cfg.user}.home != null then
            config.users.users.${cfg.user}.home
          else
            "/home/${cfg.user}";

        execArgs = [
          "${cfg.package}/bin/code"
          "tunnel"
        ]
        ++ lib.optional cfg.acceptServerLicenseTerms "--accept-server-license-terms"
        ++ lib.optionals (cfg.tunnelName != null) [
          "--name"
          cfg.tunnelName
        ]
        ++ lib.optionals (cfg.cliDataDir != null) [
          "--cli-data-dir"
          (toString cfg.cliDataDir)
        ]
        ++ lib.optionals (cfg.serverDataDir != null) [
          "--server-data-dir"
          (toString cfg.serverDataDir)
        ]
        ++ lib.optionals (cfg.extensionsDir != null) [
          "--extensions-dir"
          (toString cfg.extensionsDir)
        ]
        ++ cfg.extraArgs;
      in
      {
        environment.systemPackages = [ cfg.package ];

        systemd.services.vsc-tunnel = {
          description = "Visual Studio Code Remote Tunnel";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          path = [
            cfg.package
            pkgs.coreutils
            pkgs.git
          ];
          environment = {
            HOME = userHome;
          };
          serviceConfig = {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = userHome;
            ExecStart = lib.escapeShellArgs execArgs;
            Restart = "always";
            RestartSec = "10s";
          }
          // lib.optionalAttrs (cfg.environmentFile != null) {
            EnvironmentFile = cfg.environmentFile;
          };
        };
      };
  };
}
