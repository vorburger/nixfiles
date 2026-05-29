# `vorburger/nixfiles`

The [❄️ Nix](https://nixos.org) files of @[vorburger](https://www.vorburger.ch). (These are _"[dendritic](https://vic.github.io/dendrix/Dendritic.html)".)_

[`dotfiles` ⚆ are here](https://github.com/vorburger/dotfiles); I've also got _[🔮 `aifiles`](https://github.com/enola-dev/vorburger-ai-assistant)._

Originally explored in my [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix).
and the [`dotfiles/NixOS`](https://github.com/vorburger/dotfiles/tree/main/NixOS); TODO consolidate.

## Usage

<!-- TODO Move everything that follows into docs/ ... -->

### Test VM

Install [Nix](https://nixos.org/download) and [direnv](https://direnv.net/docs/installation.html),
and clone this repo, then `cd` (which will automagically put `nixos-rebuild` on your PATH) and run:

    vm console-vm clean
    vm gnome-vm keep

It should `ssh` into the VM. The `vorburger` user is auto-logged in for `gnome-vm`. For `console-vm` you can also (logout and) login as `tester` with password `x`.

This does not (need to install) use any bootloader, as `qemu` directly boots the kernel.

Note that `vm` requires a mandatory second argument to specify the disk state:

- `clean` deletes the `$MACH.qcow2` persistent disk image before the run. This ensures the VM starts in a "pure" state, which is required to apply certain configuration changes like `initialPassword` or disk partitioning.

- `keep` preserves the existing `$MACH.qcow2` file. This "keeps" any stateful changes made inside the VM, such as files created in home directories, installed non-declarative packages, or system logs.

### Installer ISO

    nix build .#nixosConfigurations.installer.config.system.build.isoImage
    rm -f nixos-*.iso
    cp --no-preserve=mode,ownership result/iso/nixos-minimal-*-linux.iso .

Run `./nixos-minimal-*-x86_64-linux.iso` in e.g. GNOME Boxes.
To write it to USB stick and boot a physical machine from it:

In Bash/Zsh (works automatically if there is exactly one matching file):

    sudo dd if=./nixos-*.iso of=/dev/... status=progress
    sync

In Fish shell (using inline command substitution):

    sudo dd if=(echo ./nixos-*.iso) of=/dev/... status=progress
    sync

Boot this ISO; you'll be auto logged on the console as `nixos` (without password).

#### VM

Type `ip addr` to find out the IP address assigned via DHCP.

Then SSH into it with the baked-in SSH public key as user `nixos`, for a VM probably use:

    ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.122.3

And now we can use [NixOS Anywhere](docs/docs/reference/nixos-anywhere.md) to install NixOS:

    nixos-anywhere --flake .#gnome-vm --target-host nixos@192.168.122.3

If it works and completes successfully, you can then `ssh` into the installed VM as user `vorburger`:

    ssh -A vorburger@192.168.122.3

#### BM

If it's a machine without Ethernet that needs to get on a WiFi, then use:

    nmtui
    ping 8.8.8.8
    ip addr

Let's store the IP and name of that new machine, and then do the following, in this repo, not the new machine:

    export IP=192.168.1.121
    export HOSTNEW=xyz

    mkdir modules/hosts/$HOSTNEW
    cp modules/hosts/gnome-vm.nix modules/hosts/$HOSTNEW.nix

    # TODO Automate this?
    # edit modules/hosts/$HOSTNEW.nix: Change the hostname & device

    ssh nixos@$IP "nixos-generate-config --no-filesystems --dir /tmp && cat /tmp/hardware-configuration.nix" >modules/profiles/hardware/_$HOSTNEW.nix

    mkdir -p ~/VAULT/$HOSTNEW/extra-files/etc/secrets
    mkdir -p ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections
    echo "$(mkpasswd -m sha-512)" > ~/VAULT/$HOSTNEW/extra-files/etc/secrets/vorburger-password
    # ... create your .nmconnection file in ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/ ...
    chmod 600 ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/*.nmconnection

    nixos-anywhere --extra-files ~/VAULT/$HOSTNEW/extra-files --flake .#$HOSTNEW --target-host nixos@$IP

### Maintenance

#### Remote

Change `*.nix` files for any host on any host, and then just:

    nixos-rebuild switch --flake .#$HOSTNEW --target-host $HOSTNEW --use-remote-sudo --ask-sudo-password

#### Local

Change `*.nix` files locally, and then just:

    sudo nixos-rebuild switch --flake .

## Docs

`nix build .#documentation` produces the static HTML documentation site in `result/` (built using [Zensical](https://zensical.org)).

`nix run .#watch-documentation` (or `watch-documentation` in the `nix develop` shell) serves the documentation locally with live-rebuilds.

It's published to https://nixfiles.vorburger.ch.
