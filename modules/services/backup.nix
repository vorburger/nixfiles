let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.backup = mkService {
    name = "backup";
    description = "Automatic service backups";
    extraOptions =
      { lib, config, ... }:
      {
        baseDir = lib.mkOption {
          type = lib.types.path;
          description = "Global base directory where backup jobs will write by default.";
        };
        zfs = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable automatic ZFS legacy mount generation for backup paths.";
          };
          pool = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "ZFS pool name (e.g. 'bardioc') used to identify ZFS datasets.";
          };
        };
        jobs = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  srcDir = lib.mkOption {
                    type = lib.types.path;
                    description = "Source directory of the service data.";
                  };
                  destDir = lib.mkOption {
                    type = lib.types.path;
                    default = "${config.services.backup.baseDir}/${name}";
                    defaultText = lib.literalExpression ''"''${config.services.backup.baseDir}/''${name}"'';
                    description = "Destination directory where backup will be written.";
                  };
                  sqliteDbs = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                    description = "Relative paths to SQLite databases inside the source directory to backup using sqlite3 CLI.";
                  };
                  calendar = lib.mkOption {
                    type = lib.types.str;
                    default = "daily";
                    description = "systemd timer OnCalendar schedule expression.";
                  };
                };
              }
            )
          );
          default = { };
          description = "Backup jobs configuration.";
        };
      };
    content =
      {
        cfg,
        pkgs,
        lib,
        ...
      }:
      let
        # Helper to generate the backup script for a job
        mkBackupScript = _name: job: ''
          # Ensure destination subdirectories exist
          mkdir -p "${job.destDir}/db"
          mkdir -p "${job.destDir}/files"

          # 1. Back up any specified SQLite databases cleanly using sqlite3
          ${lib.concatMapStringsSep "\n" (dbPath: ''
            dbSrc="${job.srcDir}/${dbPath}"
            dbDst="${job.destDir}/db/${builtins.baseNameOf dbPath}"
            if [ -f "$dbSrc" ]; then
              echo "Backing up SQLite database $dbSrc to $dbDst..."
              ${pkgs.sqlite}/bin/sqlite3 "$dbSrc" ".backup '$dbDst'"
            else
              echo "Error: Configured SQLite database $dbSrc does not exist!" >&2
              exit 1
            fi
          '') job.sqliteDbs}

          # 2. Sync everything else using rsync (excluding the live databases and their wal/shm logs)
          echo "Syncing other service files..."
          ${pkgs.rsync}/bin/rsync -a --delete \
            ${lib.concatMapStringsSep " " (dbPath: "--exclude='${dbPath}*'") job.sqliteDbs} \
            "${job.srcDir}/" "${job.destDir}/files/"
        '';

        services = lib.mapAttrs' (
          name: job:
          lib.nameValuePair "backup-${name}" {
            description = "Hot backup for service ${name}";
            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };
            script = mkBackupScript name job;
          }
        ) cfg.jobs;

        timers = lib.mapAttrs' (
          name: job:
          lib.nameValuePair "backup-${name}" {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnCalendar = job.calendar;
              Persistent = true;
            };
          }
        ) cfg.jobs;

        # Automatically mount ZFS datasets for paths starting with "/${pool}/" if ZFS mounts are enabled
        zfsJobs = lib.filterAttrs (
          _name: job: cfg.zfs.enable && cfg.zfs.pool != null && lib.hasPrefix "/${cfg.zfs.pool}/" job.destDir
        ) cfg.jobs;
        fileSystems = lib.mapAttrs' (
          _name: job:
          lib.nameValuePair job.destDir {
            device = lib.removePrefix "/" job.destDir;
            fsType = "zfs";
            options = [ "nofail" ];
            neededForBoot = false;
          }
        ) zfsJobs;
      in
      {
        systemd.services = services;
        systemd.timers = timers;
        inherit fileSystems;
      };
  };
}
