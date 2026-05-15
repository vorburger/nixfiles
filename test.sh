#!/usr/bin/env bash

set -euo pipefail

nix flake check

nixos-rebuild build-vm --flake .#console-grub

# TODO Fix testing the first-flake tutorial...
# cd docs/docs/tutorial/first-flake
# nix run .#cow
# cd ../../../..
