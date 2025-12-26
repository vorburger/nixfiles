#!/usr/bin/env bash
set -euxo pipefail

MACH=${1:-test1}

nixos-rebuild build-vm --flake .#"$MACH"

result/bin/run-"$MACH"-vm &

until ssh -o ConnectTimeout=7 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" vorburger@localhost -p 2222; do
  sleep 1
done

# TODO How to get the VM's IP address?
