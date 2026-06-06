# ZFS

## SMART

First, [check your disks's health](smart.md)!

TODO https://github.com/AnalogJ/scrutiny

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

    sudo mkdir /nas/vorburger
    sudo chown vorburger:vorburger /nas/vorburger
    echo "hello, world" >/nas/vorburger/hello.txt

## Pools

For `ashift`, just always keep `ashift=12`; do NOT run `lsblk -t` to adjust for PHY-SEC of 4096 with `ashift=12` (2^12 = 4096) on HDDs, and for 512 use `ashift=9` (2^9 = 512); see [the ZFS documentation for more details about why doing that would be is wrong](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Hardware.html#flash-pages).

It's highly recommended to create a reservation to prevent performance deterioration when space gets real tight, but it doesn't have to be 20% anymore; for a 8 TB mirror just 100 GB is good enough (which would allow you to `zfs destroy pool/reserved`, to temporarily unblock a tight spot to figure out a longer term solution; if it were ever needed), like so:

    sudo zfs create \
      -o encryption=off \
      -o refreservation=100G \
      -o mountpoint=none \
      -o canmount=off \
      "pool8/reserved"

BTW: The ZFS pool name `tank` often seen in other examples is just a convention, nothing more!

## Datasets

Create datasets in a pool with `zfs create` as in the TL;DR above.

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

We recommend using [`sanoid`](https://github.com/jimsalterjrs/sanoid),
because it's more flexible, and integrates with [`syncoid`](https://github.com/jimsalterjrs/sanoid#syncoid) for replication:

    services.sanoid = {
        enable = true;
        interval = "*:0/15"; # For "frequently" snapshots.
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

Alternatively, use the simpler `autoSnapshot.enable = true;`
from [zfstools](https://github.com/bdrewery/zfstools) to get automatic snapshots
such as `/nas/.zfs/snapshot/zfs-auto-snap_frequent-2026-06-06-12h30/` IFF you also do:

    $ sudo zfs set com.sun:auto-snapshot=true pool8

    $ zfs get com.sun:auto-snapshot
    NAME       PROPERTY               VALUE                  SOURCE
    pool8      com.sun:auto-snapshot  true                   local
    pool8/nas  com.sun:auto-snapshot  true                   inherited from pool8

TODO What is the value and difference of using NixOS `services.sanoid` instead of `autoSnapshot.enable = true` ?

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
