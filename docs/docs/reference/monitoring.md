# Monitoring

This repository provides two modular services for system telemetry and monitoring:

## Metrics Exporters (`services.metrics-exporter`)

Defined in `modules/services/metrics-exporter.nix`. Enabled by default on all hosts via `modules/hosts/_common.nix`.

- **`node-exporter`**: Exposes host OS system metrics (CPU, RAM, disk, systemd unit health) on `http://127.0.0.1:9100/metrics`.
- **`smartctl-exporter`**: Exposes S.M.A.R.T disk statistics and health metrics on `http://127.0.0.1:9633/metrics`.

Optionally, specific devices can be set using:

```nix
services.metrics-exporter.smartctlDevices = [ "/dev/nvme0n1" ];
```

## Monitoring Stack (`services.monitoring`)

Defined in `modules/services/monitoring.nix`. Enabled on server/monitoring hosts (currently `ixo`).

- **Prometheus**: Listens on `http://127.0.0.1:9090` and scrapes `node` and `smartctl` exporter targets.
- **Grafana**: Listens on `http://127.0.0.1:3000` for visual dashboarding.
