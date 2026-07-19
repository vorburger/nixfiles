# Rescue USB Stick

A "rescue USB" is a full, **persistent** NixOS installation on a USB stick — not a
read-only live image. You can plug it into any machine, boot it, make changes, and
those changes survive reboots. It is ideal for:

- Working on a host (like `titan`) before its internal disk is set up.
- Recovery / diagnostics when a host cannot boot from its internal drive.
- Carrying a fully-configured working environment on a pocket-sized device.

## How It Differs from a Normal Host

| Concern       | Normal host                    | Rescue USB                                |
| ------------- | ------------------------------ | ----------------------------------------- |
| Disk layout   | Production-sized, optimised FS | Simple: ESP + ext4, `noatime`             |
| Bootloader    | `canTouchEfiVariables = true`  | `canTouchEfiVariables = false` (**must**) |
| BIOS support  | Optional BIOS boot partition   | UEFI only (modern machines)               |
| `diskoDevice` | Internal NVMe/SATA             | USB stick by-id path                      |

> [!WARNING]
> `boot.loader.efi.canTouchEfiVariables` **must** be `false` on a USB.
> If set to `true`, systemd-boot will write a boot entry into the EFI NVRAM of
> whichever machine you plug the USB into, corrupting that machine's boot order.

## Repository Structure

This repository models the rescue USB as a separate host that **reuses** the
target host's NixOS modules:

- [`modules/hosts/titan-rescue.nix`](https://github.com/vorburger/nixfiles/blob/main/modules/hosts/titan-rescue.nix) —
  imports all `titan` personality modules; only `diskoDevice` and `diskoModule`
  differ.
- [`modules/disko/_usb-rescue.nix`](https://github.com/vorburger/nixfiles/blob/main/modules/disko/_usb-rescue.nix) —
  simple USB-safe disko layout (ESP + ext4, systemd-boot, no EFI var writes).

## Step 1 — Find the USB Device by-id

Always use a stable `/dev/disk/by-id/` path rather than `/dev/sdX`, which can
change between boots and machines.

```bash
ls -l /dev/disk/by-id/ | grep -v part
```

Pick the entry that matches your USB model (look for `usb-` prefix). Example output:

```
usb-Samsung_Flash_Drive_0123456789AB-0:0 -> ../../sda
```

Copy the full name (everything before `->`):

```
/dev/disk/by-id/usb-Samsung_Flash_Drive_0123456789AB-0:0
```

## Step 2 — Update titan-rescue.nix

Edit [`modules/hosts/titan-rescue.nix`](https://github.com/vorburger/nixfiles/blob/main/modules/hosts/titan-rescue.nix)
and replace the placeholder:

```nix
diskoDevice = "/dev/disk/by-id/REPLACE_WITH_YOUR_USB_BY_ID";
```

with your real by-id path from Step 1.

Commit the change:

```bash
git add modules/hosts/titan-rescue.nix
git commit -m "Set titan-rescue diskoDevice to USB by-id"
```

## Step 3 — Check the Closure Size Fits on the USB

Before wiping the stick, verify that the NixOS system closure will actually fit.
Build the system without installing it, then measure its size:

```bash
toplevel=$(nix build --print-out-paths --no-link \
  .#nixosConfigurations.titan-rescue.config.system.build.toplevel)
nix path-info --closure-size "$toplevel" | awk '{print $2}' | numfmt --to=iec-i --suffix=B
```

This prints the total closure size in human-readable IEC units (e.g. `14GiB`).
For a GNOME workstation configuration, expect **10–20 GiB** in the Nix
store alone.

| USB capacity | Verdict                                                               |
| ------------ | --------------------------------------------------------------------- |
| 8 GB         | ❌ Almost certainly too small for GNOME                               |
| 16 GB        | ⚠️ Tight — may work but little room for future `nixos-rebuild switch` |
| 32 GB        | ✅ Comfortable                                                        |
| 64 GB+       | ✅ Plenty, including headroom for `nix-collect-garbage` cycles        |

> [!TIP]
> The closure size is the Nix store footprint only. Add ~1–2 GB for the ESP,
> journal, and user data in `/home` and `/var`.

## Step 4 — Partition and Format the USB (disko)

> [!CAUTION]
> This **wipes everything** on the target device. Double-check the by-id path
> before running.

Build and execute the disko script from the flake:

```bash
script=$(nix build --print-out-paths --no-link \
  .#nixosConfigurations.titan-rescue.config.system.build.diskoScript)
sudo "$script"
```

Disko will partition the USB (GPT with ESP + ext4 root) and mount it under
`/mnt`.

## Step 5 — Install NixOS onto the USB

```bash
sudo nixos-install \
  --flake .#titan-rescue \
  --root /mnt \
  --no-root-passwd
```

This copies the entire NixOS closure (kernel, packages, your configuration) to
the USB. Depending on the USB speed, this takes several minutes.

When it finishes, you can unmount and reboot:

```bash
sudo umount -R /mnt
sudo reboot
```

## Step 6 — Boot from the USB

Enter your machine's boot menu (usually F12 / F10 / Esc at POST) and select
the USB stick. It will boot into a fully-configured NixOS with your `titan`
personality (GNOME, all your tools, SSH keys, etc.).

## Day-to-Day Usage

Once booted from the USB, use it exactly like a normal NixOS installation:

```bash
# Pull the latest config from your nixfiles repo
cd ~/git/github.com/vorburger/nixfiles

# Rebuild and switch (updates the USB itself, persistently)
sudo nixos-rebuild switch --flake .#titan-rescue
```

Changes — new packages, configuration tweaks, user files — all persist across
reboots because the USB is a real, writable installation.

## Keeping titan.nix and titan-rescue.nix in Sync

The rescue configuration intentionally imports the **same personality modules**
as the production host. When you update `titan.nix` (new services, new dotfiles,
etc.), those changes automatically apply to `titan-rescue` on the next
`nixos-rebuild switch`.

The only things that differ are:

- `diskoDevice` (USB by-id vs future internal disk)
- `diskoModule` (`_usb-rescue.nix` vs the production layout)
- `networking.hostName` (forced to `titan-rescue` for clarity)

## Troubleshooting

### Machine won't boot from USB

Check that the USB is formatted as GPT with a valid ESP. Confirm in the firmware
boot menu that UEFI mode (not Legacy/CSM) is used. The `_usb-rescue.nix` layout
does **not** include a BIOS boot partition — it requires UEFI.

### `canTouchEfiVariables` error during install

If `nixos-install` fails with an error about EFI variables, check that
`_usb-rescue.nix` has `boot.loader.efi.canTouchEfiVariables = false;`.

### USB is very slow

USB 2.0 speeds (~25 MB/s) make switching configurations painfully slow.
Prefer USB 3.x sticks and USB 3.x ports. The `noatime` mount option in the
disko layout reduces unnecessary write amplification.
