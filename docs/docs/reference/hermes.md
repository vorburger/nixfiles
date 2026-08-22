# Hermes

The `services.hermes` service module enables the [Hermes Agent](https://hermes-agent.nousresearch.com/) AI framework on a NixOS host using the Google Gemini native provider.

## Architecture

To understand how Hermes operates on NixOS:

1. **CLI (`hermes chat`, `hermes --tui`)**:
   Hermes CLI is a standalone application (not a thin RPC client). When invoked in a terminal, it executes in-process, loads `config.yaml` and `.env` from `$HERMES_HOME`, manages local SQLite databases (`state.db`, `projects.db`, memories, session history), and makes outbound HTTPS requests directly to the configured LLM API (Google Gemini).

2. **System Service (`hermes-agent.service` Gateway)**:
   The background systemd service runs `hermes gateway run`. The **Gateway** is Hermes' multi-channel messaging bridge (for connecting bots to Telegram, Discord, Slack, WhatsApp, Matrix, etc.). It listens for external chat platform events and runs background agent loops.

3. **State & Permissions (`/var/lib/hermes/.hermes`)**:
   Under the NixOS system service module:
   - The daemon runs as system user `hermes:hermes`.
   - System state, database, and declarative config live in `/var/lib/hermes/.hermes` (mode `2770`).
   - When `addToSystemPackages = true` is enabled, `HERMES_HOME` is set to `/var/lib/hermes/.hermes` so the CLI shares skills, memories, and cron sessions with the gateway service.
   - Interactive users (e.g. `vorburger`) must be members of the `hermes` group to read/write shared configuration and SQLite databases without permission errors.

## Alternatives

- **System Module (Current)**:
  Uses upstream `inputs.hermes-agent.nixosModules.default`. Best for headless servers or systems running persistent messaging gateways (Telegram, Discord, Slack) where interactive users share gateway state via the `hermes` group.
- **Home Manager Module (`homeManagerModules.default`)**:
  Upstream also provides a user-level Home Manager module. It manages Hermes purely inside the user's home directory (`~/.hermes`) with `0600`/`0700` permissions and optional `systemd.user.services.hermes-agent` for the gateway. This isolates state per user without requiring system users or shared groups.
- **Standalone CLI Package**:
  If the background gateway service is not needed at all, the package can be installed standalone (`inputs.hermes-agent.packages.${pkgs.system}.default`) without activating any systemd services.

## Configuration

Enable the service in your host configuration (e.g. `titan.nix`):

```nix
services.hermes.enable = true;
```

When enabled, this service automatically:

- Configures and starts the native Hermes systemd service (`services.hermes-agent`) configured to use Google Gemini (`gemini-flash-latest` at `https://generativelanguage.googleapis.com/v1beta`).
- Integrates the **RTK (Rust Token Killer)** CLI proxy (`pkgs.rtk`) and `rtk-hermes` plugin (`rtk-rewrite`) to intercept and compress shell command outputs (saving 60–90% LLM tokens on terminal outputs).
- Integrates the **`hermes-lcm`** (Lossless Context Management) plugin (`context.engine = "lcm"`), providing SQLite DAG-backed bounded context management with agent recall tools (`lcm_grep`, `lcm_expand`, `lcm_recall`, `lcm_recent`, etc.), with built-in context compression configured as a fallback.
- Routes session title generation (`auxiliary.title_generation`) to local `gemma4:e2b` via Ollama (`http://localhost:11434/v1`) for fast, local-first session summarization.
- Binds the encrypted API key secret `/run/secrets/hermes` (`secrets/encrypted/hermes.age`) into the Hermes environment.
- Adds user `vorburger` to the `hermes` group and sets `HERMES_HOME = "/var/lib/hermes/.hermes"` so interactive shells and the CLI use the system configuration and shared state.
- Installs the `hermes` CLI into system packages (`addToSystemPackages = true`) and sets the `h` shell alias to `hermes`.

## Secrets

Hermes requires a Google Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey).

To edit or update the encrypted secret:

```bash
ragenix -e secrets/encrypted/hermes.age
```

The file format should be:

```bash
GOOGLE_API_KEY=AIzaSy...
```

## Links

- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs/)
- [Hermes Agent Nix & NixOS Setup](https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup#nixos-module)
- [Hermes Agent Google Gemini Guide](https://hermes-agent.nousresearch.com/docs/guides/google-gemini)
- [Google AI Studio](https://aistudio.google.com/apikey)
- [Hermes Agent GitHub Repository](https://github.com/NousResearch/hermes-agent)
