#!/usr/bin/env bash
set -euxo pipefail

MACH=${1:-test1}

nixos-rebuild build-vm --flake .#"$MACH"

result/bin/run-"$MACH"-vm &

ssh vorburger@localhost -p 2222

# TODO How to make `nixos-rebuild` forward local port 2222 into the VM automatically?

# TODO How to get the VM's IP address?
