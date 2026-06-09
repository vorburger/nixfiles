# `vorburger/nixfiles`

The [❄️ Nix](https://nixos.org) files of @[vorburger](https://www.vorburger.ch). (These are _"[dendritic](https://vic.github.io/dendrix/Dendritic.html)".)_

[`dotfiles` ⚆ are here](https://github.com/vorburger/dotfiles); I've also got _[🔮 `aifiles`](https://github.com/enola-dev/vorburger-ai-assistant)._

Originally explored in my [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix).
and the [`dotfiles/NixOS`](https://github.com/vorburger/dotfiles/tree/main/NixOS); TODO consolidate.

## Usage

<!-- TODO Move everything that follows into docs/ ... -->

### Test VM

To run local virtual machines for testing your host configurations, please refer to the [Testing in Virtual Machines tutorial](docs/docs/tutorial/vm.md).

### Installation

- **Testing in Virtual Machines (VM)**: Refer to the [Testing in Virtual Machines tutorial](docs/docs/tutorial/vm.md) for lightweight dev VM, full bootable VM, and `nixos-anywhere` VM installation instructions.
- **Bare-Metal Installation (BM)**: Refer to the [Bare-Metal Installation reference](docs/docs/reference/bare-metal.md) for installer ISO creation, flashing, target host configuration, and bare-metal deployment.

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
