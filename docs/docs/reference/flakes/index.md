# Sub-Flakes & Development Environments

This repository hosts standalone sub-flakes under `flakes/` to provide standardized, reusable development environments for external repositories (such as full-stack Java and TypeScript projects).

## Available Flakes

| Flake            | Path                  | Description                                                                                    |
| :--------------- | :-------------------- | :--------------------------------------------------------------------------------------------- |
| **Java**         | `flakes/java`         | Java 25 compilation, Java 21 IDE (JDT LS), Gradle 9 override, VS Code configuration generator. |
| **Bun**          | `flakes/bun`          | Bun runtime and Node.js 26 (`npx`).                                                            |
| **Schemathesis** | `flakes/schemathesis` | Schemathesis API testing tool with Allure report integration.                                  |

## Why Sub-Flakes?

When an external repository references `github:vorburger/nixfiles`, Nix Flakes by default locks **every** input defined in `nixfiles/flake.nix` (including `disko`, `home-manager`, `ragenix`, and `antigravity`).

By placing developer toolchains in sub-directories with their own minimal `flake.nix`:

- Consuming projects only pull `nixpkgs`—never any host or NixOS dependencies.
- Sub-flakes can be consumed individually (e.g. backend-only or frontend-only) or combined.
- The root `nixfiles` verifies sub-flakes in CI via `checks`.

## Using Sub-Flakes in External Projects

### Templates

To bootstrap a new project, initialize from one of the provided templates:

- **Java-only project** (Java 25/21, Gradle 9, direnv):
  ```bash
  nix flake init -t github:vorburger/nixfiles#java
  ```
- **Full-stack Java & Bun project** (Java 25/21, Gradle 9, Bun, Node.js, direnv):
  ```bash
  nix flake init -t github:vorburger/nixfiles#java-bun
  ```

For existing repositories, refer to the runnable examples:

- [`examples/java/flake.nix`](https://github.com/vorburger/nixfiles/blob/main/examples/java/flake.nix)
- [`examples/java-bun/flake.nix`](https://github.com/vorburger/nixfiles/blob/main/examples/java-bun/flake.nix)

## Lock Synchronization

Sub-flakes keep their own `flake.lock` files to maintain isolation. To guarantee that sub-flakes never drift from the `nixpkgs` revision in the root `nixfiles/flake.lock`, running `./update.sh` automatically updates and synchronizes all `flakes/*/`:

```bash
./update.sh
```

The root flake includes a `checks.subflakes-lock-sync` check to ensure that sub-flake lock files are in sync with root `nixpkgs` during `nix-fast-build`.
