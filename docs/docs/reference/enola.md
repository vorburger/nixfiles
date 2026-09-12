# Enola

The `services.enola` module configures a systemd service to run an [Enola](https://enola.dev) Java server fat JAR under a dedicated system user, along with an automated builder service for scheduled continuous deployment of backend and frontend assets, and Caddy reverse proxy integration.

## Architecture

1. **Dedicated Service Daemon (`enola.service`)**:
   - Runs as unprivileged system user `enola:enola` under systemd.
   - Starts via `${cfg.package}/bin/java -jar ${cfg.jarPath} server ${toString cfg.port} ${cfg.extraArgs}`.
   - Default port is **`2609`** (configurable via `services.enola.port`).
   - Java runtime is **`pkgs.openjdk25_headless`**.
   - If the JAR file is missing, the service fails visibly upon start to alert the administrator.

2. **Asset Destinations**:
   - **Backend Server JAR**: `/var/lib/enola/server/enola.jar` (mode `0775`, owned by `enola-builder:enola`).
   - **Frontend Web UI**: `/var/lib/enola/ui/` (mode `0775`, owned by `enola-builder:enola`).
   - **Runtime Data Directory**: `/var/lib/enola/data/` (mode `0700`, owned by `enola:enola` on high-speed NVMe SSD).

3. **Web Serving & Reverse Proxy (`vaish.home.vorburger.ch`)**:
   - Caddy serves the frontend Single Page Application (SPA) static files from `/var/lib/enola/ui`.
   - Caddy proxies all API requests matching `/v1/*` and `/widget/*` directly to `127.0.0.1:2609`.
   - **Same-Origin API Connection**: Because both the UI and the backend API are served under `https://vaish.home.vorburger.ch`:
     - Browsers will never block requests due to Mixed Content (HTTPS -> HTTP).
     - Cross-Origin Resource Sharing (CORS) issues are eliminated.
     - The UI works seamlessly across all devices on the local network.

4. **Privilege Separation & Builder User (`enola-builder`)**:
   - Assets are owned and deployed by a dedicated system user `enola-builder:enola-builder`.
   - The runtime `enola` daemon only has _read_ access to `/var/lib/enola/server` and `/var/lib/enola/ui`, preventing the running server from modifying its own binaries.
   - User `vorburger` is intentionally excluded from write permissions on the deployment targets to enforce least privilege and prevent accidental manual mutations.
   - The builder user works inside `/var/lib/enola-builder`, completely isolated from `/home/vorburger` (which is `0700`).

5. **Automated Scheduled Builder (`services.enola.builder.enable`)**:
   - When enabled, systemd timer `enola-builder.timer` runs periodically (`OnCalendar = "hourly"` by default).
   - Executes `enola-builder.service`, which clones/updates `enola2` and `enola2ui`, builds the fat JAR and frontend, copies them to `/var/lib/enola/server/enola.jar` and `/var/lib/enola/ui/`, and restarts `enola.service`.

6. **Backup Integration**:
   - Integrated with [`services.backup`](backup.md) on host `titan` to automatically back up `/var/lib/enola/data` daily to `/bardioc/services/enola`.

## Configuration

Enable the service in your host configuration (e.g. `titan.nix`):

```nix
services.enola = {
  enable = true;
  port = 2609;
  # jarPath = "/var/lib/enola/server/enola.jar";
  # uiDir = "/var/lib/enola/ui";
  # dataDir = "/var/lib/enola/data";
  # package = pkgs.openjdk25_headless;
  builder = {
    enable = !vmTest; # enable automated hourly builder on bare metal
    calendar = "hourly";
  };
};
```

And in `services.backup.jobs`:

```nix
services.backup.jobs.enola = {
  srcDir = "/var/lib/enola/data";
};
```

## Options

- `services.enola.enable`: Whether to enable the Enola server systemd service.
- `services.enola.port`: Port number for the server (defaults to `2609`).
- `services.enola.jarPath`: Filesystem path to the fat JAR (defaults to `/var/lib/enola/server/enola.jar`).
- `services.enola.uiDir`: Filesystem path to the frontend assets (defaults to `/var/lib/enola/ui`).
- `services.enola.dataDir`: Working directory and data directory for the server (defaults to `/var/lib/enola/data`).
- `services.enola.package`: OpenJDK package used to run the JAR (defaults to `pkgs.openjdk25_headless`).
- `services.enola.extraArgs`: List of additional string arguments passed to the server invocation.
- `services.enola.builder.enable`: Whether to enable the automated builder service and timer (defaults to `false`).
- `services.enola.builder.calendar`: Systemd calendar schedule for the builder timer (defaults to `"hourly"`).

## Secrets

Because `enola2` and `enola2ui` are private GitHub repositories, the scheduled builder requires authentication. To avoid requiring interactive hardware security keys (such as YubiKeys), the service uses `ragenix` to manage an encrypted GitHub Personal Access Token (PAT):

- Declared via `mkSecret` in `modules/services/enola.nix`.
- Encrypted file: `secrets/encrypted/enola-github-token.age` (mode `0400`, owned by `enola-builder:enola-builder`).
- Decrypted at boot time by titan's host key into `/run/secrets/enola-github-token`.
- Automatically consumed by `enola-builder` via `git config url."https://x-access-token:${TOKEN}@github.com/".insteadOf` without any interactive prompts.

To edit or set the GitHub token:

```bash
ragenix -e secrets/encrypted/enola-github-token.age
```

## Service Management & Logs

Check server status:

```bash
systemctl status enola
```

Follow server logs:

```bash
journalctl -u enola -f
```

Trigger a manual run of the builder service:

```bash
sudo systemctl start enola-builder.service
journalctl -u enola-builder -f
```
