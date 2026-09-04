#!/usr/bin/env bash

# DEPRECATED!! Instead, prefer updating Flake inputs using:
#   - .agents/skills/nix-update skill on your local machine, and
#   - dependabot auto-merge workflow on GitHub

set -euo pipefail

nix flake update
nix run .#write-flake

# Synchronize all sub-flakes to root nixfiles/flake.lock nixpkgs revision
NIXPKGS_REV=$(jq -r '.nodes.nixpkgs.locked.rev' flake.lock)
for flake_dir in flakes/*/; do
  if [ -f "$flake_dir/flake.nix" ]; then
    echo "Synchronizing $flake_dir to nixpkgs $NIXPKGS_REV..."
    (cd "$flake_dir" && nix flake lock --override-input nixpkgs "github:NixOS/nixpkgs/$NIXPKGS_REV")
  fi
done

nix flake check
