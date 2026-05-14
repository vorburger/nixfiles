#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <machine> <clean|keep>"
  exit 1
fi

MACH=$1
MODE=$2

if [ "$MODE" == "clean" ]; then
  rm -f "$MACH.qcow2"
elif [ "$MODE" == "keep" ]; then
  true
else
  echo "Invalid mode: $MODE (must be 'clean' or 'keep')"
  exit 1
fi

nixos-rebuild build-vm --flake .#"$MACH"

result/bin/run-"$MACH"-vm &

until ssh -o ConnectTimeout=7 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" vorburger@127.0.0.1 -p 2222; do
  sleep 1
done

# TODO How to get the VM's IP address?
