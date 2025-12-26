# `vorburger/nixfiles`

The [❄️ Nix](https://nixos.org) files of @[vorburger](https://www.vorburger.ch). (These are _"[dendritic](https://vic.github.io/dendrix/Dendritic.html)".)_

[`dotfiles` ⚆ are here](https://github.com/vorburger/vorburger-dotfiles-bin-etc); I've also got _[🔮 `aifiles`](https://github.com/enola-dev/vorburger-ai-assistant)._

Originally explored in my [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix).
and the [`dotfiles/NixOS`](https://github.com/vorburger/vorburger-dotfiles-bin-etc/tree/main/NixOS); TODO consolidate.

## Usage

### Test VM

Install [Nix](https://nixos.org/download) and [direnv](https://direnv.net/docs/installation.html),
and clone this repo, then `cd` (which will automagically put `nixos-rebuild` on your PATH) and run:

    bin/vm.sh test1

It should `ssh` into the VM (alternatively, you can login as `tester` with password `x` on the Console).

### Installer ISO

    nix build .#nixosConfigurations.installer.config.system.build.isoImage
    sudo chown vorburger:vorburger result/iso/nixos-minimal-*-linux.iso

Run `result/iso/nixos-minimal-*-x86_64-linux.iso` in e.g. GNOME Boxes; login on the console as `nixos` (without password), or SSH into it as `nixos` user with the baked-in SSH public key.

To write it to USB stick and boot a physical machine from it:

    sudo dd if=result/iso/nixos-*.iso of=/dev/... status=progress

## Docs

`nix build .#documentation` produces the static HTML documentation site in `result/`.

`nix run .#watch-documentation` serves the documentation locally with live-rebuilds
