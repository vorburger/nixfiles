# Bare-Metal Installation (BM)

This reference documents how to install NixOS on physical bare-metal hardware using `nixos-anywhere` and an installer ISO.

## Prerequisites

1. **Build the Installer ISO**:

   ```bash
   nom build .#nixosConfigurations.installer.config.system.build.isoImage
   rm -f nixos-*.iso
   cp --no-preserve=mode,ownership result/iso/nixos-minimal-*-linux.iso .
   ```

2. **Flash to USB**:
   Write the ISO image to a USB flash drive (replace `TARGET_DRIVE` with the appropriate block device, e.g., `/dev/sdX`):
   - **Bash/Zsh**:
     ```bash
     lsblk
     sudo dd if=./nixos-*.iso of=${TARGET_DRIVE:? "Set TARGET_DRIVE!"} status=progress
     sync
     ```
   - **Fish**:
     ```fish
     lsblk
     sudo dd if=(echo ./nixos-*.iso) of=$TARGET_DRIVE status=progress
     sync
     ```

3. **Boot Physical Machine**:
   Insert the USB drive into the target bare-metal machine, boot from it, and log in. The installer ISO automatically logs in to the console as the `nixos` user with no password.

## Installation Steps

1. **Network Setup**:
   If the target machine requires WiFi to connect to the internet, configure it using `nmtui`:

   ```bash
   nmtui
   ping 8.8.8.8
   ip addr
   ```

2. **Retrieve Hardware Configuration**:
   Run the following commands on your development machine (not the new target host) using the target machine's temporary IP address:

   ```bash
   export IP=192.168.1.121
   export HOSTNEW=xyz

   ssh nixos@$IP "nixos-generate-config --no-filesystems --dir /tmp && cat /tmp/hardware-configuration.nix" >modules/profiles/targets/KIND-OF-HOST.nix
   ```

   _Note: Edit `KIND-OF-HOST.nix` to align it with standard target profiles (e.g., `modules/profiles/targets/x1_12.nix`)._

3. **Configure the New Host**:
   Create a new host configuration file:

   ```bash
   cp modules/hosts/ixo(-vm).nix modules/hosts/$HOSTNEW.nix
   ```

   _Note: Edit `modules/hosts/$HOSTNEW.nix` to match the target hostname and layout/devices (e.g., `/dev/nvme0n1`)._

4. **Verify Flake Evaluation**:
   Before initiating installation, verify your configuration is clean and valid:

   ```bash
   nix flake check
   ```

5. **Deploy with `nixos-anywhere`**:
   Deploy the configuration to the target machine:

   ```bash
   nixos-anywhere --flake .#$HOSTNEW --target-host nixos@$IP
   ```

   _Optional: If you need to copy private system configurations (like NetworkManager connection profiles) from a local vault during deployment:_

   ```bash
   mkdir -p ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections
   # ... create connection file under this path ...
   chmod 600 ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/*.nmconnection

   nixos-anywhere --extra-files ~/VAULT/$HOSTNEW/extra-files --flake .#$HOSTNEW --target-host nixos@$IP
   ```

---

## Important System Administration Notes

### `system.stateVersion`

- **What it is**: `system.stateVersion` is set to the NixOS release version when the machine was first installed. It ensures that stateful services use backwards-compatible behaviors.
- **Upgrades**: **Do NOT change** this version number when performing standard system upgrades.
- **Wiping & Reinstalling**: If you choose to completely wipe and reinstall a bare-metal machine (rather than performing an in-place upgrade), you **should** update the `system.stateVersion` in its host file to the new version you are deploying.
