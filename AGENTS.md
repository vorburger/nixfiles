# Nix for Agents

- Whenever there are any formatting errors, just run `nix fmt`.
- After making any and for each change to `*.nix` files, always execute `nix flake check` to run various tests which verify everything is OK.
- Because this project is based on https://flake.parts, never add `specialArgs = { inherit pkgs; };` or similar to any `modules/**/*.nix` files.
- When committing files, do not use prefixes like "fix(nixos):". Instead, start the message with the action taken.
- There is no NixOS `x88_64` "system" (CPU type), it's a LLM-generated typo mistake; use `x86_64-linux` instead.
- Because this project uses https://github.com/vic/import-tree, the `flake.nix` always has **ALL** `modules/**/*.nix` files.
  So there is never any need to manually edit `flake.nix` to add or remove any `*.nix` files.
