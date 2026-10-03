# VS Code Tunnel

The `services.vsc-tunnel` service module configures a persistent [Visual Studio Code Remote Tunnel](https://code.visualstudio.com/docs/remote/tunnels) systemd service.

## Overview

VS Code Remote Tunnels allow you to securely connect to a remote NixOS host from [vscode.dev](https://vscode.dev) or the VS Code desktop client via Microsoft's port-forwarding service, without requiring an open incoming port, dynamic DNS, or a VPN.

When enabled, the service runs `code tunnel` continuously in the background under the designated user account.

## Configuration

Enable the service in a host configuration (such as `modules/hosts/titan.nix`):

```nix
services.vsc-tunnel = {
  enable = true;
};
```

### Options

- `services.vsc-tunnel.enable`: (default: `false`) Enables the VS Code Remote Tunnel systemd service.
- `services.vsc-tunnel.package`: (default: `pkgs.vscode`) Package providing the `code` binary.
- `services.vsc-tunnel.user`: (default: `"vorburger"`) The user account under which the service runs.
- `services.vsc-tunnel.group`: (default: `"vorburger"`) The group under which the service runs.
- `services.vsc-tunnel.tunnelName`: (default: `null`) Custom tunnel name. When set to `null`, the machine hostname is used.
- `services.vsc-tunnel.acceptServerLicenseTerms`: (default: `true`) Automatically accepts the VS Code Server license terms without interactive prompting.
- `services.vsc-tunnel.cliDataDir`: (default: `null`) Directory where CLI metadata and authentication credentials are saved. When `null`, defaults to `~/.vscode/cli` under the user's home directory.
- `services.vsc-tunnel.serverDataDir`: (default: `null`) Directory where server data is stored.
- `services.vsc-tunnel.extensionsDir`: (default: `null`) Directory where extensions are installed.
- `services.vsc-tunnel.environmentFile`: (default: `null`) Path to an environment file (e.g. a decrypted secret) containing environment variables such as `VSCODE_CLI_ACCESS_TOKEN` or `VSCODE_CLI_REFRESH_TOKEN` for non-interactive authentication.
- `services.vsc-tunnel.extraPackages`: (default: `[ ]`) Additional packages to include in the service's `PATH`.
- `services.vsc-tunnel.extraArgs`: (default: `[ ]`) Extra CLI arguments passed to `code tunnel`.

> [!NOTE]
> Enabling `services.vsc-tunnel` automatically sets `services.nix-ld.enable = true` by default. This is required because VS Code Server and its Marketplace extensions download pre-compiled dynamic Linux ELF binaries that depend on standard glibc paths. The service environment also provides `bash` (`sh`), core tools, `/run/current-system/sw/bin`, and per-user profile paths so integrated terminals and server lifecycle scripts execute cleanly.

## Authentication

A tunnel requires authentication with either GitHub or Microsoft.

### Interactive Login (Default)

Before or after starting the service, log into the tunnel service as the configured user:

```bash
code tunnel user login
```

Follow the browser device code prompt to authenticate. Once authenticated, credentials are stored in `~/.vscode/cli` and the background service will automatically use them to establish the connection.

To verify login status:

```bash
code tunnel user show
```

### Headless / Secret-Based Login

For headless installations without manual interactive login, you can provide an environment file containing an authentication token via `environmentFile`:

```nix
services.vsc-tunnel = {
  enable = true;
  environmentFile = "/run/secrets/vsc-tunnel";
};
```

where `/run/secrets/vsc-tunnel` defines:

```bash
VSCODE_CLI_ACCESS_TOKEN="<token>"
# or
VSCODE_CLI_REFRESH_TOKEN="<token>"
```

## Management

Check service status:

```bash
systemctl status vsc-tunnel
```

Inspect service logs:

```bash
journalctl -u vsc-tunnel -f
```

Check tunnel status using the CLI:

```bash
code tunnel status
```
