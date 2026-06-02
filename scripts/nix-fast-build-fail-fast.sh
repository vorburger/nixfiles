#!/usr/bin/env bash

# Runs nix-fast-build with full parallelism but exits immediately on the first
# build or evaluation failure (fail-fast), instead of collecting all errors.
#
# Works around (or rather, is pending...) upstream
# https://github.com/Mic92/nix-fast-build/pull/342
# for https://github.com/Mic92/nix-fast-build/issues/341.

set -eo pipefail

tmpfifo=$(mktemp -u)
mkfifo "$tmpfifo"
trap 'rm -f "$tmpfifo"' EXIT

# Start nix-fast-build with stderr redirected to our fifo
nix-fast-build "$@" 2>"$tmpfifo" &
NFB_PID=$!

# Monitor stderr: pass all lines through, but kill nix-fast-build on first failure
while IFS= read -r line; do
  echo "$line" >&2
  # nix-fast-build logs "WARNING:nix_fast_build:build <attr> exited with <N>"
  # on any build or eval failure.
  if [[ $line == *"exited with"* || $line == *": Failed "* ]]; then
    kill "$NFB_PID" 2>/dev/null || true
    wait "$NFB_PID" 2>/dev/null || true
    echo "nix-fast-build-fail-fast: killed after first failure (fail-fast)" >&2
    exit 1
  fi
done <"$tmpfifo"

wait "$NFB_PID"
