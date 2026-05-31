# Testing NixOS Configurations in Virtual Machines

This tutorial documents how to build and test your NixOS host configurations locally inside virtual machines (VMs).

To support different validation needs, this repository provides two distinct VM runner commands in the `nix develop` environment: `vm` and `vmb`.

---

## 🏃🏽‍♀️ Quick Comparison

| Command   | VM Type            | Boot Process                             | Disk Partitioning                   | Encryption (LUKS)                     | Best For                                                                     |
| :-------- | :----------------- | :--------------------------------------- | :---------------------------------- | :------------------------------------ | :--------------------------------------------------------------------------- |
| **`vm`**  | Lightweight Dev VM | Direct kernel boot (bypasses bootloader) | Bypassed / RAM rootfs               | Bypassed / Plain text mount           | Fast development cycles, tweaking config options, fast reboots               |
| **`vmb`** | Full Bootable VM   | UEFI + **systemd-boot**                  | Evaluates **Disko** partition table | Encrypted volumes (e.g. `/home` LUKS) | Testing full layout, boot order, initrd systemd flow, and unlock passphrases |

---

## 🏎️ `vm` - Lightweight Dev VM

The `vm` script utilizes NixOS's built-in QEMU runner to boot the kernel directly from the host. This is the fastest way to verify standard system changes.

### Usage

```bash
vm <host-name> <clean|keep>
```

- **`clean`**: Deletes the persistent VM disk state (`<host-name>.qcow2`) before running, forcing an initial clean boot.
- **`keep`**: Preserves existing state (such as files created inside `/home` or `/var`).

### Example

To test the `gnome-vm` host configuration with a clean state:

```bash
vm gnome-vm clean
```

Once the VM successfully boots, the command will **automatically SSH into the VM guest shell** for you.

---

## 🔒 `vmb` - Full Partition Bootable VM (Disko / LUKS / UEFI)

The `vmb` (VM Boot) script generates a complete sparse raw disk image using your host's configured **Disko** layouts, formats it, installs the bootloader, and runs a full virtual boot lifecycle.

This is critical to test layout configurations (such as ZFS partitions, LVM, and LUKS) and the systemd initrd boot phase.

### Usage

```bash
vmb <host-name> <clean|keep>
```

- **`clean`**: Deletes the local raw disk (`<host-name>-disk.raw`) and the UEFI variables NVRAM file (`<host-name>-efivars.fd`).
- **`keep`**: Boots using the existing disk image and NVRAM variables.

### Example

To test the `vinea` host layout (which uses an encrypted home partition and systemd-boot bootloader):

```bash
vmb vinea clean
```

Just like `vm`, once the VM successfully boots and finishes launching the SSH daemon, `vmb` will **automatically SSH into the VM guest shell**.

### 🔑 LUKS Decryption Test & Passphrase Flow

The `vmb` tool uses a temporary passphrase file containing the password `x` and copies it into the VM build environment as `/tmp/luks.secret` using `--pre-format-files`.

1. When the VM starts, a QEMU window will display the **systemd-boot** bootloader menu.
2. After loading the kernel, the initrd phase will halt and prompt you for the decryption passphrase for the `/home` partition (`crypt-home`).
3. Click inside the QEMU window, type **`x`**, and hit `Enter` to decrypt the drive.
4. Once unlocked, the VM will boot, and your host terminal will automatically connect via SSH.

For details on how the LUKS configuration is declared, or how it is formatted on bare-metal machines, see the [Disko Layouts reference](../reference/disko-layouts.md).

---

## 💿 Testing Installation via nixos-anywhere in a VM

If you want to test the full installation cycle of a host configuration (e.g. `gnome-vm`) from the bootable installer ISO using [nixos-anywhere](../reference/nixos-anywhere.md):

1. **Build the Installer ISO**:
   ```bash
   nom build .#nixosConfigurations.installer.config.system.build.isoImage
   rm -f nixos-*.iso
   cp --no-preserve=mode,ownership result/iso/nixos-minimal-*-linux.iso .
   ```
2. **Boot the ISO**: Run the generated `./nixos-minimal-*-x86_64-linux.iso` image in a VM hypervisor like **GNOME Boxes** or virt-manager.
3. **Log in & Get IP**: The ISO will auto-login on the console as user `nixos` (no password). Run `ip addr` inside the VM to find the assigned DHCP IP address (e.g., `192.168.122.3`).
4. **SSH to Installer**: Verify you can SSH into the installer VM using the baked-in SSH public key:
   ```bash
   ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.122.3
   ```
5. **Run nixos-anywhere**: From your host shell, trigger the installation onto the VM:
   ```bash
   nixos-anywhere --flake .#gnome-vm --target-host nixos@192.168.122.3
   ```
6. **Verify Installed System**: Once complete and rebooted, SSH into the installed VM as your standard user:
   ```bash
   ssh -A vorburger@192.168.122.3
   ```

---

## 👤 VM Credentials

- **User Accounts**: The VM is configured with your default user `vorburger`.
- **Graphical Login**: The Gnome graphical interface auto-logs in the `vorburger` user.
- **Console Login**: If testing via console login, you can log in as `tester` with password `x`.
- **Guest SSH**: Guest port `22` is forwarded to host port `2222`. Both tools will SSH automatically, but you can also manually connect via:
  ```bash
  ssh -p 2222 vorburger@localhost
  ```
