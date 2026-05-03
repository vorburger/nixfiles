# `nix` CLI

## Installation

We currently recommend using the [Determinate Systems Nix](determinate.md) distribution of Nix, as it's the easiest way to get started with Nix today.

Alternatively, you can also install `nix` from https://nixos.org/download.

On Fedora Linux (44+), you can simply `sudo dnf install nix`.

This course only uses the "modern" Nix CLI, with commands like `nix run` (note the space before the sub-command),
rather than the "legacy" Nix CLI with commands like `nix-env -i` and `nix-shell` (note the dash style commands).

If you use `nix` from `nixos.org` instead of the Determinate, then you'll need to enable the "flakes" feature by running:

```sh
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
