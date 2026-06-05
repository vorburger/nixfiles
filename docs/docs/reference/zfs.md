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

    sudo zfs create -o mountpoint=/nas pool8/nas

## Pools

For `ashift`, just always keep `ashift=12`; do NOT run `lsblk -t` to adjust for PHY-SEC of 4096 with `ashift=12` (2^12 = 4096) on HDDs, and for 512 use `ashift=9` (2^9 = 512); see [the ZFS documentation for more details about why doing that would be is wrong](https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Hardware.html#flash-pages).

BTW: The name `tank` often seen in examples is just a convention, nothing more!

## Datasets

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

### zpool history

    sudo zpool history pool8

## Encryption

TODO How to mount encrypted datasets at boot, with `keylocation=prompt` - without storing the passphrase in plain text in public Git repo? Check NixOS, and see also https://wiki.archlinux.org/title/ZFS#Native_encryption.

    zfs change-key pool8

    zfs change-key -o keyformat=raw -o keylocation=zfs-key pool8

It's instantaneous, and does not need to rewrite or re-encrypt any of your data.

## Cache

## Snapshots

## Backup

TODO How to backup to Google Drive? https://github.com/someone1/zfsbackup-go,

## Monitoring

TODO https://github.com/pdf/zfs_exporter

## Deduplication

TODO With https://github.com/openzfs/zfs/discussions/15896, is it still very slow?

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
