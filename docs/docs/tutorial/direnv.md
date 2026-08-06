# Automatic Shell Environments with `direnv`

[`direnv`](https://direnv.net/) is an extension for your shell that automatically loads and unloads environment variables depending on your current directory.

In a Nix repository with a `flake.nix`, `direnv` seamlessly integrates with `nix develop` to load your project's development shell whenever you `cd` into the project directory.

---

## 1. Enabling `direnv` in your Shell

`direnv` must be hooked into your shell configuration once. For NixOS configurations, `programs.direnv.enable = true` handles shell integration automatically.

For manual shell configs:

- **Bash** (`~/.bashrc`):

  ```bash
  eval "$(direnv hook bash)"
  ```

- **Fish** (`~/.config/fish/config.fish`):
  ```fish
  direnv hook fish | source
  ```

---

## 2. Setting up `.envrc` in a Flake Repository

To instruct `direnv` to load a Nix Flake development shell, create a `.envrc` file in the root of your project:

```bash
use flake
```

The first time you create or modify `.envrc`, `direnv` blocks execution for security. Allow it by running:

```bash
direnv allow
```

---

## 3. How Shell Reloading Works

When you `cd` into the repository, `direnv` checks the cached development environment:

- **Automatic Reload**: `direnv` monitors `.envrc`, `flake.nix`, and `flake.lock`. Changes to these files will automatically trigger a reload.
- **Manual Reload**: If you edit nested `**/*.nix` files and want to force `direnv` to pick up newly added packages immediately without leaving the directory, run:
  ```bash
  direnv reload
  ```
  _(Note: Running `cd .` does not trigger a reload if `direnv` detects that the active directory path hasn't changed)._
