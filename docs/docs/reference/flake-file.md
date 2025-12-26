# `flake-file`

https://github.com/vic/flake-file allows to generate `flake.nix` entirely from modules.

Inputs are added in the module which requires it via `flake-file.inputs.XYZ.url`.

To avoid a _"chicken-and-egg" problem,_ always first add only the `flake-file.inputs.home-manager.url` to a `modules/*.nix`.

`nix run .#write-flake && flake.nix` then rewrites `flake.nix`.

Only then can you add references to `inputs.XYZ` in `imports` of modules.
