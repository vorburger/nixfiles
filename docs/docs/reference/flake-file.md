# `flake-file`

https://github.com/vic/flake-file allows to generate `flake.nix` entirely from modules.

Inputs are added in the module which requires it via `flake-file.inputs.XYZ.url`.

To avoid a _"chicken-and-egg" problem,_ always first add only this.

`nix run .#write-flake && flake.nix` then rewrites `flake.nix`.

Only then can you add references to `inputs.XYZ`, in modules.
