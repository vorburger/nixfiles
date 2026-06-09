# `vorburger/nixfiles`

The [❄️ Nix](https://nixos.org) files of @[vorburger](https://www.vorburger.ch). (These are _"[dendritic](https://vic.github.io/dendrix/Dendritic.html)".)_

[`dotfiles` ⚆ are here](https://github.com/vorburger/dotfiles); I've also got _[🔮 `aifiles`](https://github.com/enola-dev/vorburger-ai-assistant)._

Originally explored in my [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix).
and the [`dotfiles/NixOS`](https://github.com/vorburger/dotfiles/tree/main/NixOS); TODO consolidate.

## Usage

<!-- TODO Move everything that follows into docs/ ... -->

### Test VM

To run local virtual machines for testing your host configurations, please refer to the [Testing in Virtual Machines tutorial](docs/docs/tutorial/vm.md).

### Installer ISO

    nom build .#nixosConfigurations.installer.config.system.build.isoImage
    rm -f nixos-*.iso
    cp --no-preserve=mode,ownership result/iso/nixos-minimal-*-linux.iso .

Run `./nixos-minimal-*-x86_64-linux.iso` in e.g. GNOME Boxes.
To write it to USB stick and boot a physical machine from it:

In Bash/Zsh (works automatically if there is exactly one matching file):

    lsblk
    sudo dd if=./nixos-*.iso of=${TARGET_DRIVE:? "Set TARGET_DRIVE!"} status=progress
    sync

In Fish shell (using inline command substitution):

    lsblk
    sudo dd if=(echo ./nixos-*.iso) of=$TARGET_DRIVE status=progress
    sync

Boot this ISO; you'll be auto logged on the console as `nixos` (without password).

#### VM

For step-by-step instructions on installing NixOS into a VM using `nixos-anywhere` and the Installer ISO, please refer to the [Testing Installation via nixos-anywhere in a VM section of the Testing in Virtual Machines tutorial](docs/docs/tutorial/vm.md#testing-installation-via-nixos-anywhere-in-a-vm).

#### BM

If it's a machine without Ethernet that needs to get on a WiFi, then use:

    nmtui
    ping 8.8.8.8
    ip addr

Let's store the IP and name of that new machine, and then do the following, in this repo, not the new machine:

    export IP=192.168.1.121
    export HOSTNEW=xyz

    ssh nixos@$IP "nixos-generate-config --no-filesystems --dir /tmp && cat /tmp/hardware-configuration.nix" >modules/profiles/targets/KIND-OF-HOST.nix
    # edit KIND-OF-HOST.nix to make it like modules/profiles/targets/x1_12.nix etc.

    cp modules/hosts/ixo(-vm).nix modules/hosts/$HOSTNEW.nix
    # edit modules/hosts/$HOSTNEW.nix: Change the hostname & device=/dev/...
    # Note on system.stateVersion: This defines the NixOS release version when the machine was first installed.
    # Do NOT change it when upgrading. However, if you wipe and re-install (not just upgrade) the machine,
    # update `system.stateVersion` in its host file to the new version you are installing.
    nix flake check

    nixos-anywhere --flake .#$HOSTNEW --target-host nixos@$IP

Or, optionally:

    mkdir -p ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections
    # ... create your .nmconnection file in ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/ ...
    chmod 600 ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/*.nmconnection

    nixos-anywhere --extra-files ~/VAULT/$HOSTNEW/extra-files --flake .#$HOSTNEW --target-host nixos@$IP

### Maintenance

#### Remote

Change `*.nix` files for any host on any host, and then just:

    nixos-rebuild switch --flake .#$HOSTNEW --target-host $HOSTNEW --sudo --ask-sudo-password

#### Local

Change `*.nix` files locally, and then just:

    sudo nixos-rebuild switch --flake .

## Docs

`nix build .#documentation` produces the static HTML documentation site in `result/` (built using [Zensical](https://zensical.org)).

`nix run .#watch-documentation` (or `watch-documentation` in the `nix develop` shell) serves the documentation locally with live-rebuilds.

It's published to https://nixfiles.vorburger.ch.
