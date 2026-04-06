#!/usr/bin/env bash
set -euo pipefail

# 1. Detect if we need to disable sandboxing/seccomp (common in restricted environments like some CI/VMs)
# Nix sandboxing requires unprivileged user namespaces AND seccomp.
CAN_SANDBOX=false
if unshare --user --map-root-user true 2>/dev/null; then
  CAN_SANDBOX=true
elif [ -f /proc/sys/kernel/apparmor_restrict_unprivileged_userns ] && [ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns)" = "1" ]; then
  # On modern systems like Ubuntu 24.04+, unprivileged userns are restricted by default.
  # We try to enable it if we have sudo privileges.
  echo "Info: Attempting to enable unprivileged user namespaces via sysctl..."
  if sudo -n sysctl -w kernel.apparmor_restrict_unprivileged_userns=0 >/dev/null 2>&1; then
    if unshare --user --map-root-user true 2>/dev/null; then
      CAN_SANDBOX=true
    fi
  else
    echo "Warning: Unable to modify kernel.apparmor_restrict_unprivileged_userns (no non-interactive sudo). Continuing without enabling unprivileged user namespaces."
  fi
fi

# Even if namespaces are supported, seccomp might be missing (e.g. in some container runtimes like Jules)
# prctl(PR_GET_SECCOMP, 0, 0, 0, 0) returns EINVAL (22) if the kernel doesn't support seccomp.
if [ "$CAN_SANDBOX" = "true" ]; then
  SECCOMP_SUPPORTED=false
  if [ -d /proc/sys/kernel/seccomp ]; then
    SECCOMP_SUPPORTED=true
  elif python3 -c 'import ctypes; PR_GET_SECCOMP=21; res=ctypes.CDLL(None).prctl(PR_GET_SECCOMP, 0, 0, 0, 0); exit(0 if res != -1 else 1)' 2>/dev/null; then
    SECCOMP_SUPPORTED=true
  fi

  if [ "$SECCOMP_SUPPORTED" = "false" ]; then
    echo "Warning: Seccomp not supported by kernel. Disabling Nix sandboxing."
    CAN_SANDBOX=false
  fi
fi

# 2. Install Nix (Determinate Systems installer is recommended for CI/VMs)
# Check if nix is already available in the PATH or in the default profile
if ! command -v nix >/dev/null 2>&1 && [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
  # If we cannot sandbox, we must tell the installer NOT to try it during its own setup/tests
  if [ "$CAN_SANDBOX" = "false" ]; then
    echo "Info: Installing Nix with sandbox disabled."
    # Passing them individually without extra quotes
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --extra-conf "sandbox = false" --extra-conf "filter-syscalls = false"
  else
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  fi
fi

# 3. Find and source Nix
# Source the Nix profile so 'nix' is available in the current shell
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Set NIX_BIN for use in starting the daemon if needed
NIX_BIN=$(command -v nix || echo "/nix/var/nix/profiles/default/bin/nix")

if [ ! -x "$NIX_BIN" ]; then
  echo "Error: nix binary not found or not executable at $NIX_BIN." >&2
  false
fi

# 4. Configure Nix
sudo mkdir -p /etc/nix
if [ "$CAN_SANDBOX" = "true" ]; then
  echo "Info: Nix sandboxing will remain enabled (default)."
  sudo tee /etc/nix/nix.custom.conf >/dev/null <<'CONF'
# Nix sandboxing remains enabled because unprivileged user namespaces and seccomp are supported.
extra-experimental-features = nix-command flakes
CONF
else
  echo "Warning: Disabling Nix sandboxing and syscall filtering in config."
  cat <<'CONF' | sudo tee /etc/nix/nix.custom.conf >/dev/null
sandbox = false
filter-syscalls = false
extra-experimental-features = nix-command flakes
CONF
fi

# Ensure our custom config is actually included in the main nix.conf
if ! grep -q "nix.custom.conf" /etc/nix/nix.conf 2>/dev/null; then
  echo "!include nix.custom.conf" | sudo tee -a /etc/nix/nix.conf >/dev/null
fi

# 5. Start Daemon (if not already managed by systemd/installer)
if [ ! -e /nix/var/nix/daemon-socket/socket ]; then
  sudo pkill nix-daemon || true
  sudo "$NIX_BIN-daemon" 2>&1 | sudo tee /var/log/nix-daemon.log >/dev/null &
  sleep 2
fi

# 6. Export Path
PATH="$(dirname "$NIX_BIN"):$PATH"
export PATH

# 7. Verify the installation
nix --version
nix flake --help >/dev/null
echo "Nix installation and configuration complete."
