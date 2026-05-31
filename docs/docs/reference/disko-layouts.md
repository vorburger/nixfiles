# Disko Layouts

This repository uses [disko](https://github.com/nix-community/disko) to declare host disk layouts.

## Host Wiring

Disk layout selection happens in each host file through mkHost:

```nix
mkHost {
  name = "example";
  diskoDevice = "/dev/nvme0n1";
  # Optional override; default is ../modules/disko/_boot-and-ext4.nix
  diskoModule = ../disko/_learn-zfs.nix;
  modules = [ ... ];
}
```

If diskoModule is not set, mkHost keeps using the default layout at modules/disko/\_boot-and-ext4.nix.

## Vinea learn-zfs Layout

Vinea now uses modules/disko/\_learn-zfs.nix.

That layout is intentionally opinionated and more advanced:

- Pure UEFI boot: no BIOS boot partition.
- boot.initrd.systemd.enable = true.
- boot.loader.systemd-boot.enable = true.
- LVM volume group vg0 on the main disk.
- Logical volumes:
  - / as ext4 (50G)
  - /nix as ext4 (100G)
  - /home as LUKS-encrypted btrfs (200G)
  - /var/lib as XFS (remaining free space)
- Three GPT partitions typed for ZFS (zfs1, zfs2, zfs3), intentionally left empty.

## Initializing Reserved ZFS Partitions Manually

The reserved ZFS partitions are created but not used by NixOS configuration.
Initialize them manually when ready.

1. Inspect partition names and paths:

```bash
ls -l /dev/disk/by-partlabel
```

1. Confirm the three reserved partitions exist:

```bash
ls -l /dev/disk/by-partlabel/zfs1 /dev/disk/by-partlabel/zfs2 /dev/disk/by-partlabel/zfs3
```

1. Example: initialize one partition as a simple pool:

```bash
sudo zpool create data /dev/disk/by-partlabel/zfs1
```

1. Example: create datasets for large stateful workloads:

```bash
sudo zfs create -o mountpoint=/var/lib/containers data/containers
sudo zfs create -o mountpoint=/var/lib/libvirt/images data/vm-images
sudo zfs create -o mountpoint=/var/lib/postgresql data/postgresql
```

## Notes

- This layout assumes a reasonably large disk; adjust LV and partition sizes if needed.
- /home encryption uses LUKS managed through the systemd-based initrd flow.
- /var/lib was chosen as the default location for containers, VM images, and database state.
