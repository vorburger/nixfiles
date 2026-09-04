# Java Development Environment Template

This example demonstrates how external repositories consume the `java` sub-flake from `vorburger/nixfiles` without pulling unnecessary NixOS system dependencies.

## Usage

### Option A: Initialize a New Repository

You can initialize a new repository using this template via `nix flake init`:

```bash
nix flake init -t github:vorburger/nixfiles#java
```

### Option B: Add to an Existing Flake

To use the `java` sub-flake in an existing project, see the complete example implementation in [flake.nix](./flake.nix).

## Features Included

- **Java Compilation**: OpenJDK 25 headless.
- **Java IDE Tooling**: OpenJDK 21 headless for VS Code Language Server (JDT LS) and Gradle daemon, avoiding OSGi Equinox compatibility crashes on Linux/NixOS.
- **Gradle**: Gradle 9 overridden with Java 25.
- **VS Code Settings**: Automatic generation of `.vscode/settings.json` configured with JavaSE-25 and JavaSE-21 runtimes and import filters.
- **Direnv Support**: Includes `.envrc` that automatically loads the Nix flake environment and optional `.envrc.local`.
- **Minimal Dependencies**: Consumes only `nixpkgs`—zero transitive host/system dependencies from `nixfiles`.
