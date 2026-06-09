# Firmware Update

The `fwupd` service is enabled on this system via `nixfiles/modules/services/fwupd-extra.nix`.

## Notification & Auto-Refresh

You do not need to manually refresh the firmware metadata or constantly poll for updates:

1. The systemd service `fwupd-refresh.timer` automatically runs `fwupdmgr refresh` in the background to keep the local firmware database updated.
2. A Fish shell startup hook runs once a day when you open an interactive terminal. It checks the local cached database and prints a warning if updates are available. See [`dotfiles`](https://github.com/vorburger/dotfiles/commit/a6af1c9b067063b64214228e973dc25fa2c7be20).

## Usage

When notified of available firmware updates, you only need to run:

```bash
fwupdmgr update
```

Other commands for inspection:

- `fwupdmgr get-devices` - List all detected hardware devices supporting updates.
- `fwupdmgr get-updates` - List details of available updates for your devices.

## References

- https://wiki.archlinux.org/title/Fwupd
- https://en.wikipedia.org/wiki/Fwupd
- https://fwupd.org
