# `vorburger/nixfiles`

The [❄️ Nix](https://nixos.org) files of @[vorburger](https://www.vorburger.ch). (These are _"[dendritic](https://vic.github.io/dendrix/Dendritic.html)".)_

[`dotfiles` ⚆ are here](https://github.com/vorburger/vorburger-dotfiles-bin-etc); I've also got _[🔮 `aifiles`](https://github.com/enola-dev/vorburger-ai-assistant)._

Originally explored in my [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix).
and the [`dotfiles/NixOS`](https://github.com/vorburger/vorburger-dotfiles-bin-etc/tree/main/NixOS); TODO consolidate.

## Usage

<!-- TODO Move everything that follows into docs/ ... -->

### Test VM

Install [Nix](https://nixos.org/download) and [direnv](https://direnv.net/docs/installation.html),
and clone this repo, then `cd` (which will automagically put `nixos-rebuild` on your PATH) and run:

    bin/vm.sh test1

It should `ssh` into the VM (alternatively, you can login as `tester` with password `x` on the Console).

This does not (need to install) use any bootloader, as `qemu` directly boots the kernel. (TODO Remove the Disko and GRUB bits from `test1.nix`.)

### Installer ISO

    nix build .#nixosConfigurations.installer.config.system.build.isoImage
    sudo chown vorburger:vorburger result/iso/nixos-minimal-*-linux.iso

Run `result/iso/nixos-minimal-*-x86_64-linux.iso` in e.g. GNOME Boxes.
To write it to USB stick and boot a physical machine from it:

In Bash/Zsh:

    sudo dd if=$(realpath result/iso/nixos-*.iso) of=/dev/... status=progress

In Fish shell:

    sudo dd if=(realpath result/iso/nixos-*.iso) of=/dev/... status=progress

Boot this ISO; you'll be auto logged on the console as `nixos` (without password).

#### VM

Type `ip addr` to find out the IP address assigned via DHCP.

Then SSH into it with the baked-in SSH public key as user `nixos`, for a VM probably use:

    ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" nixos@192.168.122.3

And now we can use [NixOS Anywhere](docs/docs/reference/nixos-anywhere.md) to install NixOS:

    nix run github:nix-community/nixos-anywhere -- --flake .#vm1 --target-host nixos@192.168.122.3

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
    cp modules/hosts/vm1/configuration.nix modules/hosts/$HOSTNEW/

    # TODO Automate this?
    # edit modules/hosts/$HOSTNEW/configuration.nix: Change the hostname (twice) & device

    ssh nixos@$IP "nixos-generate-config --no-filesystems --dir /tmp && cat /tmp/hardware-configuration.nix" >modules/hosts/$HOSTNEW/_hardware-configuration.nix

    mkdir -p ~/VAULT/$HOSTNEW/extra-files/etc/secrets
    mkdir -p ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections
    echo "$(mkpasswd -m sha-512)" > ~/VAULT/$HOSTNEW/extra-files/etc/secrets/vorburger-password
    # ... create your .nmconnection file in ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/ ...
    chmod 600 ~/VAULT/$HOSTNEW/extra-files/etc/NetworkManager/system-connections/*.nmconnection

    nix run github:nix-community/nixos-anywhere -- --extra-files ~/VAULT/$HOSTNEW/extra-files --flake .#$HOSTNEW --target-host nixos@$IP

### Maintenance

#### Remote

Change `*.nix` files for any host on any host, and then just:

    nixos-rebuild switch --flake .#$HOSTNEW --target-host $HOSTNEW --use-remote-sudo --ask-sudo-password

#### Local

## Docs

`nix build .#documentation` produces the static HTML documentation site in `result/`.

`nix run .#watch-documentation` serves the documentation locally with live-rebuilds
