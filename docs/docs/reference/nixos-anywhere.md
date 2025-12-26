# `nixos-anywhere` Install NixOS Anywhere

- https://github.com/nix-community/nixos-anywhere
- https://nix-community.github.io/nixos-anywhere/
- https://nixos-anywhere.readthedocs.io/en/latest/

## Test

    nix run github:nix-community/nixos-anywhere -- --flake .#vm1 --vm-test

## Install

    nix run github:nix-community/nixos-anywhere -- --flake .#vm1 --target-host nixos@192.168.122.3
