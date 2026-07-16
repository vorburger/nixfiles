# ZFS

## Drives

Disk Drives are not all created as equals - by far not.

For example, mixing a (typically cheaper) _[Shingled Magnetic Recording](https://en.wikipedia.org/wiki/Shingled_Magnetic_Recording)_ (SMR) drive
into a ZFS mirror with a (better) _[Conventional Magnetic Recording](https://en.wikipedia.org/wiki/Perpendicular_recording)_ (CMR) drive is a massive anti-pattern;
this can cause writes at expected roughly ~200MB/s-ish to drop 10x down to ~20MB/s!

And putting a 5400-RPM and a 7200-RPM drive next to each other in a chassis creates an asynchronous vibration pattern.

Instead of buying different brands so they don't all fail at the exact same time, buy drives of similar-ish NAS drive models from the same brand.
To break up the "same batch curse", while keeping the underlying drive controllers, RPMs, firmware behavior, and physical geometry identical,
you could buy them from different vendors to get a few months variation; when buying 2nd hand, perhaps even some years apart.

## SMART

First, [check your disks's health](smart.md)!

## TL;DR

    sudo zpool create \
      -o autoexpand=off \
      -O compression=lz4 \
      -O recordsize=256K \
      -O dnodesize=auto \
      -o ashift=12 \
      -O atime=off \
      -O acltype=off \
      -O xattr=sa \
      -O normalization=formD \
      -O encryption=on \
      -O keyformat=passphrase \
      -O keylocation=prompt \
      -O mountpoint=none \
      pool8 mirror \
      /dev/disk/by-id/ata-WDC_WD80PUZX-64NEAY0_VK0GUMLY \
      /dev/disk/by-id/ata-ST8000AS0002-1NA17Z_Z840N805

    sudo bash -c 'chattr +i /nas'
    sudo zfs create -o mountpoint=/nas pool8/nas

    sudo mkdir /nas/test
    sudo chown $USER: /nas/test
    echo "hello, world" >/nas/test/hello.txt

PS: The ZFS pool name `tank` often seen in other examples is just a convention, nothing more!

## Pools

For `ashift`, just always keep `ashift=12`; do NOT run `lsblk -t` to adjust for PHY-SEC of 4096 with `ashift=12` (2^12 = 4096) on HDDs, and for 512 use `ashift=9` (2^9 = 512); see [the ZFS documentation for more details about why doing that would be is wrong](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Hardware.html#flash-pages).

It's highly recommended to create a reservation to prevent performance deterioration when space gets real tight, but it doesn't have to be 20% anymore; for a 8 TB mirror just 100 GB is good enough (which would allow you to `zfs destroy pool/reserved`, to temporarily unblock a tight spot to figure out a longer term solution; if it were ever needed), like so:

    sudo zfs create \
      -o encryption=off \
      -o refreservation=100G \
      -o mountpoint=none \
      -o canmount=off \
      "pool8/reserved"

## Datasets

Create datasets in a pool with `zfs create` as in the TL;DR above.

### NixOS Declarative Mounts

To manage ZFS mount points declaratively in NixOS (e.g. in your `fileSystems` configuration), follow these recommendations:

1. **`mountpoint=legacy`**: By default, ZFS manages dataset mounting itself using the dataset's `mountpoint` property. However, the NixOS systemd-based mounting generator requires standard mount commands. To allow NixOS to mount datasets via `fileSystems` entries, set the ZFS dataset mountpoint to `legacy`:

   ```bash
   sudo zfs set mountpoint=legacy pool8/nas
   ```

2. **`options = [ "nofail" ];`**: When mounting optional datasets (like data disks or backup targets that might be missing or disconnected), always include `options = [ "nofail" ];` in your NixOS `fileSystems` definition. Without `nofail`, systemd treats the mount as a critical boot dependency, causing the system to crash or enter an infinite emergency mode loop if the ZFS pool/disk is unavailable. With `nofail`, systemd will gracefully skip the mount if the pool import fails or times out.

## Import

    $ zpool status
    no pools available

    $ sudo zpool import
    $ sudo zpool import pool8

    $ sudo zfs mount -l pool8/nas

This (with `-l`) will ask for the passphrase.

[`ZFS-8000-4J`](https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J/)
documents how it handles if a device is missing; hint: it still works - that's the point!
(On reconnecting the missing drive it will have to [scrub](#scrub) for a few hours.)

[See here how to automatically have the pool imported at boot, with passphrase](https://github.com/vorburger/nixfiles/commit/5fb545dae24cd7d7b68dfe6223b89d43bcf752c2).

## Status

### zfs list

    $ zfs list
    NAME        USED  AVAIL  REFER  MOUNTPOINT
    pool8       888K  7.14T   192K  none
    pool8/nas   192K  7.14T   192K  /nas

### zpool status

    $ zpool status
    pool: pool8
    state: ONLINE
    config:

        NAME                                   STATE     READ WRITE CKSUM
        pool8                                  ONLINE       0     0     0
        mirror-0                               ONLINE       0     0     0
            ata-WDC_WD80PUZX-64NEAY0_VK0GUMLY  ONLINE       0     0     0
            ata-ST8000AS0002-1NA17Z_Z840N805   ONLINE       0     0     0

    errors: No known data errors

Note that `READ`, `WRITE`, and `CKSUM` represent the count of I/O errors for read operations, write operations, and checksum validation failures, respectively. Ideally, these should all be zero, indicating that the pool is healthy and there are no issues with the underlying storage devices. If you see non-zero values, it may indicate potential problems with the pool or the disks, and further investigation would be warranted to identify and resolve any issues.

### zpool history

    sudo zpool history pool8

## Encryption

Encryption is enabled in the TL;DR above; the key can be changed like this:

    zfs change-key pool8

    zfs change-key -o keyformat=raw -o keylocation=zfs-key pool8

It's instantaneous, and does not need to rewrite or re-encrypt any of your data.

## Snapshots

We recommend using _[Sanoid](https://github.com/jimsalterjrs/sanoid)_ for Snapshots, like this:

```nix
    services.sanoid = {
      enable = true;
      interval = "*:0/15"; # For "frequently" snapshots.
      datasets = lib.genAttrs (
        map (fs: fs.device) (
          lib.filter (fs: fs.fsType == "zfs") (lib.attrValues config.fileSystems)
        )
      ) (_name: {
        useTemplate = [ "default" ];
        recursive = true;
      });
      templates = {
        "default" = {
          frequently = 8; # Keep this many snapshots @15min frequency.
          hourly = 48;
          daily = 90;
          weekly = 30;
          monthly = 24;
          yearly = 100;
        };
      };
    };
```

### Difference between NixOS `services.sanoid` and `autoSnapshot.enable` (zfstools)

We recommend [`sanoid`](https://github.com/jimsalterjrs/sanoid) over [`zfstools`](https://github.com/bdrewery/zfstools) because:

1. **Integration**: `sanoid` integrates cleanly with [`syncoid`](https://github.com/jimsalterjrs/sanoid#syncoid) for ZFS [replication](#replication).
1. **Configuration**: `sanoid` is configured purely declaratively in the Nix configuration via `services.sanoid.datasets` (or dynamically mapped from `config.fileSystems`, as shown above). `zfstools` relies on setting ZFS properties on datasets and requires you to imperatively run `zfs set com.sun:auto-snapshot=true <dataset>` on the CLI.
1. **Policy Flexibility**: `sanoid` supports customizable templates, retention policies (e.g. keeping varying numbers of hourly, daily, monthly snapshots), and pre/post-snapshot scripts. `zfstools` has hardcoded retention defaults that are harder to customize.
1. **Maintenance**: `sanoid` (written in Perl) is actively maintained and the industry standard for ZFS snapshot management. `zfstools` is an older, relatively inactive Ruby-based tool.

## Cache

TODO L2ARC with an SSD, for read caching? Or will it trash the SSD with too much writes if it's an old one?

## Backup

### rsync

    rsync -aHAXx --info=progress2 --inplace /mnt/source/ /nas/...

- `-aHAXx` The Bulletproof Archive Mode:
  - `-a` (archive) copies recursively and preserves symlinks, devices, permissions, and modification times.

  - `-H` preserves hard links.

  - `-A` preserves ACLs (important since you set up posixacl).

  - `-X` preserves extended attributes (xattr=sa).

  - `-x` stays on a single filesystem (prevents rsync from accidentally backing up virtual dirs like /proc or crossing into other mounts).

  - `--inplace` (Crucial for ZFS performance): By default, rsync creates a hidden temporary file, copies the data, and then moves it into place. --inplace forces rsync to write directly to the target file. On ZFS, this avoids massive write amplification, bypasses unnecessary fragmentation, and reduces transactional overhead.

  - `--info=progress2`: Instead of scrolling a wall of text for every single tiny file (which slows down the terminal emulator), this gives you a single, modern, live-updating progress bar for the entire transfer size.

Optionally, depending on the use case, you may also want to add:

- `--numeric-ids`: Tells rsync to map user/group IDs by their raw numbers rather than trying to resolve usernames. This is much cleaner when moving data between different OS installations or environments.

### Replication

TODO syncoid

### Google Drive

TODO How to backup to Google Drive? https://github.com/someone1/zfsbackup-go,

## Monitoring

TODO https://github.com/pdf/zfs_exporter

## Deduplication

TODO With https://github.com/openzfs/zfs/discussions/15896, is it still very slow?

## Scrub

Automatic [scrubbing](https://openzfs.github.io/openzfs-docs/man/master/8/zpool-scrub.8.html) is enabled, note:

    $ zpool status
      pool: pool8
     state: ONLINE
      scan: scrub in progress since Sat Jun  6 16:56:23 2026
    	852G / 852G scanned, 28.7G / 852G issued at 70.3M/s
    	0B repaired, 3.37% done, 03:20:02 to go
    config:

    	NAME                                   STATE     READ WRITE CKSUM
    	pool8                                  ONLINE       0     0     0
    	  mirror-0                             ONLINE       0     0     0
    	    ata-WDC_WD80PUZX-64NEAY0_VK0GUMLY  ONLINE       0     0     0
    	    ata-ST8000AS0002-1NA17Z_Z840N805   ONLINE       0     0     0

    errors: No known data errors

and later, hopefully:

    $ zpool status
      pool: pool8
     state: ONLINE
      scan: scrub repaired 0B in 03:14:43 with 0 errors on Sat Jun  6 20:11:06 2026
    config:

    	NAME                                   STATE     READ WRITE CKSUM
    	pool8                                  ONLINE       0     0     0
    	  mirror-0                             ONLINE       0     0     0
    	    ata-WDC_WD80PUZX-64NEAY0_VK0GUMLY  ONLINE       0     0     0
    	    ata-ST8000AS0002-1NA17Z_Z840N805   ONLINE       0     0     0

    errors: No known data errors

You can also manually trigger scrubbing with `zpool scrub -a -w`.
This is recommended after _"resilvering"_ completes when you replace a drive.

## UI

- https://github.com/webzfs/webzfs with https://github.com/webzfs/webzfs/issues/162
- https://github.com/45Drives/cockpit-zfs or https://github.com/brycelarge/cockpit-zfs-manager
- https://github.com/ad4mts/zfdash
- https://github.com/macgaver/zfsnas-chezmoi

## Boot

NixOS can be made to boot from ZFS directly (modulo one VFAT for UEFI)

## Distros

ZFS is well integrated into NixOS; on other distros it may be slightly more of a PITA.

https://www.truenas.com is a storage distro built around ZFS.

## References

- https://wiki.archlinux.org/title/ZFS
- https://openzfs.org
