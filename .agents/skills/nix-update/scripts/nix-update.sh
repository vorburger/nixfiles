#!/usr/bin/env bash
set -euo pipefail

# Get all root inputs from flake.lock via nix flake metadata
INPUTS=$(nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys[]')

SUCCESSES=()
FAILURES=()

for input in $INPUTS; do
  echo "========================================"
  echo ">>> Updating input: $input"

  # Save the current state of flake.lock
  cp flake.lock flake.lock.bak

  if nix flake update "$input"; then
    echo ">>> Running nix flake check for $input..."
    if nix flake check; then
      echo ">>> [SUCCESS] Updated $input successfully."
      rm -f flake.lock.bak
      SUCCESSES+=("$input")
    else
      echo ">>> [FAILURE] nix flake check failed for $input. Reverting..."
      mv flake.lock.bak flake.lock
      FAILURES+=("$input")
    fi
  else
    echo ">>> [FAILURE] nix flake update failed for $input. Reverting..."
    mv flake.lock.bak flake.lock
    FAILURES+=("$input")
  fi
done

echo ""
echo "========================================"
echo "Update Summary:"
echo "✅ Successful updates (${#SUCCESSES[@]}): ${SUCCESSES[*]:-None}"
echo "❌ Failed updates (${#FAILURES[@]}): ${FAILURES[*]:-None}"
echo "========================================"
