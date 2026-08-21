# Hermes

The `services.hermes` service module enables the [Hermes Agent](https://hermes-agent.nousresearch.com/) AI framework on a NixOS host.

## Configuration

Enable the service in your host configuration (e.g. `titan.nix`):

```nix
services.hermes.enable = true;
```

When enabled, this service automatically:

- Configures and starts the native Hermes systemd service (`services.hermes-agent`).
- Installs the `hermes` CLI into system packages (`addToSystemPackages = true`) and exports `HERMES_HOME` system-wide so that interactive shells share state, memories, sessions, and cron tasks with the service.

## Links

- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs/)
- [Hermes Agent Nix & NixOS Setup](https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup#nixos-module)
- [Hermes Agent GitHub Repository](https://github.com/NousResearch/hermes-agent)
