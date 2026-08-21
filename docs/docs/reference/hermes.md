# Hermes Agent Reference

[Hermes Agent](https://hermes-agent.nousresearch.com/) by Nous Research is an AI agent framework.

The `modules/services/hermes.nix` module exposes `services.hermes-agent` (via `hermes-agent.nixosModules.default`). By default, it runs as a native, hardened systemd service without containerization.

## Usage

Import the module (e.g. via `self.nixosModules.hermes`) and enable the service:

```nix
{ config, ... }:
{
  services.hermes-agent = {
    enable = true;
    # Model configuration
    settings.model.default = "anthropic/claude-sonnet-4";

    # Secrets (at minimum, an API key for the chosen provider)
    environmentFiles = [ config.age.secrets."hermes-env".path ];

    # Put the hermes CLI on system PATH and export HERMES_HOME system-wide
    addToSystemPackages = true;
  };
}
```

## Native Mode vs Container Mode

By default, `container.enable` is `false`. In native mode:

- Runs as a hardened systemd service on the host (`NoNewPrivileges`, `ProtectSystem=strict`, `PrivateTmp`).
- Uses Nix-managed Python dependencies and tools without requiring Docker/Podman or an external container image.

If container mode is explicitly desired in the future, set `services.hermes-agent.container.enable = true`.

## Links

- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs/)
- [Hermes Agent Nix & NixOS Setup](https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup#nixos-module)
