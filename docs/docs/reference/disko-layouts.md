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

## Updating or Changing Disko Layouts on Existing Hosts

> [!WARNING]
> Running `nixos-rebuild switch --flake .#<host> --target-host <host> --sudo --ask-sudo-password` (or similar) after modifying a host's Disko partition layout will completely break the target system.
>
> NixOS's `nixos-rebuild` tries to mount new systems according to `/etc/fstab` and reload system services. However, it cannot dynamically re-partition or format mounted, active drives on a running system. Disko does not detect active layout mismatches to fail gracefully, which causes the rebuild process to crash, leaving filesystems unmounted and rendering the host unbootable.

### Why is there no "force format" flag or option?

You might wonder if you can pass a flag to `nixos-rebuild` or add an option in Nix to force formatting. This is not supported due to two core constraints:

- **Safety**: Automatically formatting/partitioning during a rebuild would risk wiping your running system's data on a simple typo or configuration update.
- **Kernel Limitations**: The active operating system has `/` and `/nix` mounted and in use. The Linux kernel will refuse to delete or re-partition active, mounted disk blocks.

### Let Disko Wipe and Recreate

Because the disk layout cannot be changed on a running OS, the layout must be rewritten from outside the active system:

#### 💻 For Virtual Machines (tested via `vmb` or QEMU)

If the host is a virtual machine, you do not need a live installer:

1. Stop the VM.
2. Delete the virtual disk image file (e.g., `vinea.qcow2` or similar) on the host machine.
3. Re-run your VM boot/build command (`vmb` or `nix run .#vm`). This will automatically trigger Disko to partition, format, and build a fresh disk image from scratch.

#### 🖥️ For Physical Hosts / Bare-Metal

1. **Boot into an Installer**:
   Boot the target host from a NixOS installer environment (e.g. NixOS installation USB/ISO, or a netboot image).

2. **Retrieve the Flake**:
   Clone or pull your `nixfiles` repository onto the installer environment.

3. **Run the Disko Script**:
   Each host configuration in this repository builds a custom `diskoScript` that contains the layout, filesystem options, and disk overrides (e.g., `diskoDevice`) configured for that specific host in the flake.

   Build and execute the script directly from the flake:

   ```bash
   # Build the diskoScript derivation for the target host (e.g., vinea)
   script=$(nix build --print-out-paths --no-link .#nixosConfigurations.vinea.config.system.build.diskoScript)

   # Execute the script to wipe partition tables, format disks, and mount everything
   # WARNING: This will destroy all existing data on the configured disks!
   sudo "$script"
   ```

4. **Proceed with Clean Install**:
   Once the script finishes, the new layout filesystems are mounted under `/mnt`. You can then proceed with `nixos-install` or your standard provisioning flow.

---

## Notes

- This layout assumes a reasonably large disk; adjust LV and partition sizes if needed.
- `/home` encryption uses LUKS managed through the systemd-based initrd flow.
- `/var/lib` was chosen as the default location for containers, VM images, and database state.
