# Home Manager

## Prerequisites

- Have [the `nix` CLI Nix installed](../reference/nix-cli.md)
- You do NOT require a NixOS system for this; any Linux distribution or macOS will do.

## Declarative User Environments

The `nix run nixpkgs#hello` command which you ran in [the previous tutorial](nixpkgs-hello.md) ran `hello` in a temporary environment.

Contrary to what you may be used to from other package managers (like `apt` DNF or `dnf` RPM), this did not actually "permanently install" anything on your system, yet.

You might want to have `hello` available all the time on the `PATH` of your user account. (And then many other programs as well, of course; but let's keep it simple, for now.)

You can achieve this with [Home Manager](https://github.com/nix-community/home-manager), which allows you to declaratively manage your user environment.

_**TODO** Crash-course for non-NixOS Flake-based Home Manager setup, see https://github.com/vorburger/dotfiles/tree/main/dotfiles/home-manager ..._
