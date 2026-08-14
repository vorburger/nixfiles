# Lix

[Lix](https://lix.systems) is an independent, community-driven variant and modern fork of the Nix package manager.

## Why Lix?

- **Improved Evaluator Performance**: Lix optimizes Nix evaluation (string handling, attribute lookups, memory usage), providing faster evaluation times for large configurations like NixOS and Flakes.
- **Superior Error Messages**: Clear, colorful, and accurate stack traces and code snippets when evaluation fails.
- **Bug Fixes**: Fixes several edge-case evaluator bugs, memory leaks, and store lock contention issues.

## Usage in NixOS

In this repository, Lix is enabled in the `nix-extra` service module ([`modules/services/nix-extra.nix`](https://github.com/vorburger/nixfiles/blob/main/modules/services/nix-extra.nix)):

```nix
nix.package = pkgs.lix;
```

It is also included in the default `devShell` so that development tools and scripts run with Lix.
