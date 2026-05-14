#!/usr/bin/env bash

# DEPRECATED!! Instead, prefer updating Flake inputs using:
#   - .agents/skills/nix-update skill on your local machine, and
#   - dependabot auto-merge workflow on GitHub

set -euo pipefail

nix flake update
nix run .#write-flake
nix flake check
./test.sh
