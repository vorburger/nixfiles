# Schemathesis Sub-Flake

This sub-flake packages [Schemathesis](https://github.com/schemathesis/schemathesis) (a property-based API testing tool for OpenAPI/GraphQL schemas) along with Allure reporting integration.

It depends only on `nixpkgs`, ensuring that consumer repositories do not pull along unnecessary NixOS/host system dependencies.

## Usage

### 1. Running Locally (from `nixfiles` repository)

> [!NOTE]
> In the Nix CLI, use `nix run` (not `nix flake run`), and prefix local directory paths with `./` so Nix resolves them as filesystem paths rather than registry identifiers. Arguments after `--` are passed directly to Schemathesis.

- Check version:
  ```bash
  nix run ./flakes/schemathesis -- --version
  ```
- Run tests against an API schema:
  ```bash
  nix run ./flakes/schemathesis -- run https://example.com/openapi.json
  ```
- Enter an interactive shell with `schemathesis` in `PATH`:
  ```bash
  nix shell ./flakes/schemathesis
  ```

### 2. Running Remotely (from any directory or machine)

You can run or enter a shell with `schemathesis` directly from GitHub without cloning:

- Run directly:
  ```bash
  nix run "github:vorburger/nixfiles?dir=flakes/schemathesis" -- --version
  ```
- Interactive shell:
  ```bash
  nix shell "github:vorburger/nixfiles?dir=flakes/schemathesis"
  ```

### 3. Consuming in another `flake.nix`

Add the sub-flake to your project's inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    schemathesis = {
      url = "github:vorburger/nixfiles?dir=flakes/schemathesis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, schemathesis, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          schemathesis.packages.${system}.default
        ];
      };
    };
}
```
