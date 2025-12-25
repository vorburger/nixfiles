#!/usr/bin/env bash

set -euo pipefail

nix flake update
nix run .#write-flake
nix flake check
./test.sh
