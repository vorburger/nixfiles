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
  - /var/lib as XFS (50G)
  - /home as LUKS-encrypted btrfs (remaining ~270G on the 500G disk)
- Three GPT partitions typed for ZFS (zfs1, zfs2, zfs3; 10G each), intentionally left empty.

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

## LUKS Encryption & Passphrase Flows

The `/home` partition layout on `vinea` (configured in [\_learn-zfs.nix](../../../modules/disko/_learn-zfs.nix)) uses LUKS encryption (`type = "luks"`) with Btrfs.

To enable automated formatting and installations, the layout declares:

```nix
passwordFile = "/tmp/luks.secret";
```

The `passwordFile` property tells `disko` where to read the decryption passphrase from **during formatting and installation time**. It is **not** used or baked into the system after it boots; at boot time, NixOS relies on the interactive console or keyfiles to unlock the drive.

Here is exactly how the `/tmp/luks.secret` file is populated and used depending on the target environment:

### 💻 Local VM Testing (with `vmb`)

When building and booting a local VM using the `vmb` tool:

1. **Passphrase Creation**: The `vmb` command automatically generates a temporary passphrase file on the host machine containing the dummy password `x`.
2. **Injecting into Build Environment**: `vmb` calls the `disko` image generation script using the `--pre-format-files` flag. This copies the temporary host passphrase file into the build environment as `/tmp/luks.secret` before partitioning begins.
3. **LUKS Formatting**: The `disko` layout reads the dummy passphrase `x` from `/tmp/luks.secret` and formats the encrypted LUKS container on the virtual disk image.
4. **Boot Decryption**: At boot time, the initrd phase halts and prompts for the decryption passphrase (`crypt-home`) on the QEMU graphical console. Because it was formatted with `x`, you click in the QEMU window, type `x`, and hit `Enter` to decrypt.

For step-by-step instructions on running this VM test, see the [Testing in Virtual Machines tutorial](../tutorial/vm.md).

### 🖥️ Bare-Metal Installation

When installing on physical hardware (e.g., using `nixos-anywhere` or the manual console installer):

1. **Passphrase Choice**: Before running the installation, you (the administrator) choose your own secure target passphrase.
2. **Writing the Secret**: On the target machine's installer environment (or inside the nixos-anywhere extra-files), you must manually create `/tmp/luks.secret` containing your real passphrase:
   ```bash
   echo -n "my-real-secure-passphrase" > /tmp/luks.secret
   ```
   > [!IMPORTANT]
   > Make sure to use `echo -n` to avoid writing a trailing newline into the password file, which would become part of your passphrase!
3. **LUKS Formatting**: When you run `disko` or `nixos-anywhere`, the installation script reads `/tmp/luks.secret` and formats the LUKS container with your real passphrase.
4. **Boot Decryption**: Once the installation is complete and the system reboots, NixOS will prompt you on the physical console to input your secure passphrase at every boot to unlock `/home`.

---

## Notes

- This layout assumes a reasonably large disk; adjust LV and partition sizes if needed.
- `/home` encryption uses LUKS managed through the systemd-based initrd flow.
- `/var/lib` was chosen as the default location for containers, VM images, and database state.
