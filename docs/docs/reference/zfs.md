# ZFS

## SMART

First, [check disks's health](smart.md).

TODO https://github.com/AnalogJ/scrutiny

## Pools

    zpool create \
      -o ashift=12 \ # SSD only?
      -o autoexpand=off \
      -O compression=lz4 \

      -O atime=off \
      -O xattr=sa \

      -O encryption=on \
      -O keyformat=hex \ # passphrase?

      -O mountpoint=legacy \

      -O dnodesize=auto \
      -O normalization=formD \
      -R /mnt/titan-home \
      titan-home raidz2 /dev/sda /dev/sdb /dev/sdc /dev/sdd

PS: The name `tank` often seen in examples is just a convention, nothing more.

## Datasets

    zfs create -o mountpoint=legacy titan-home/home
    zfs create -o mountpoint=legacy titan-home/var

## Status

    zdb -C
    zfs list
    zfs list -r
    zfs get all -s local -t filesytem | snaphot
    zpool status
    zpool status -v

## Encryption

TODO

## Compression

https://pve.proxmox.com/wiki/ZFS_on_Linux#zfs_compression

## Cache

## Snapshots

## Backup

TODO How to backup to Google Drive? https://github.com/someone1/zfsbackup-go,

## Monitoring

https://github.com/pdf/zfs_exporter

## Deduplication

https://github.com/openzfs/zfs/discussions/15896 ?

Very slow?

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
