#!/usr/bin/env bash
set -euxo pipefail

MACH=${1:-test1}

nixos-rebuild build-vm --flake .#"$MACH"

QEMU_NET_OPTS="hostfwd=tcp::2222-:22" result/bin/run-"$MACH"-vm &

ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" vorburger@localhost -p 2222

# TODO How to get the VM's IP address?
