# Services Backup Reference

The `services.backup` module provides a declarative and reusable way to configure live backups for stateful applications (such as Jellyfin) on NixOS, safely handling SQLite databases and other files.

## How it Works

When a backup job is defined, the module dynamically creates:

1. **A systemd service (`backup-<name>.service`)**:
   - Triggers an online hot-backup (`.backup`) of configured SQLite database files.
   - Performs an `rsync` of all other files to the destination directory (excluding the active database files and their WAL/SHM sidecars to prevent corruption).
2. **A systemd timer (`backup-<name>.timer`)**: Schedules the job to run daily (by default) or on a custom schedule.
3. **Automatic ZFS Mounts**: If `zfs.enable` is `true` and a `zfs.pool` is defined, the module automatically generates a legacy NixOS `fileSystems` mount configuration for any job directory starting with `/${pool}/`.

---

## Setting up a New Job (e.g. Jellyfin)

### 1. Create and configure the ZFS dataset

Configure the service backup datasets as **legacy mounts** so that mounting is managed by NixOS/systemd.

```bash
# Create the dataset
sudo zfs create -p bardioc/services/jellyfin

# Set its mountpoint property to legacy
sudo zfs set mountpoint=legacy bardioc/services/jellyfin
```

### 2. Configure NixOS

Add the backup job to your host configuration (e.g. `titan.nix`). Specify the `baseDir` and ZFS `pool` at the host level:

```nix
services.backup = {
  enable = true;
  baseDir = "/bardioc/services";
  zfs = {
    enable = !vmTest;
    pool = "bardioc";
  };
  jobs.jellyfin = {
    srcDir = "/var/lib/jellyfin";
    sqliteDbs = [
      "data/jellyfin.db"
    ];
  };
};
```

---

## Testing & Troubleshooting

### Trigger a manual backup

You can force a backup to run at any time using:

```bash
sudo systemctl start backup-jellyfin.service
```

### Check service logs

```bash
journalctl -u backup-jellyfin.service
```

### Verify backups

Ensure the directory structure and files were copied correctly:

```bash
ls -la /bardioc/services/jellyfin/db
ls -la /bardioc/services/jellyfin/files
```
