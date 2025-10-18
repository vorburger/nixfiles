# Nix for Agents

- Whenever there are any formatting errors, just run `nix fmt`.
- After making any and for each change to `*.nix` files, always execute `nix flake check` to run various tests which verify everything is OK.
- Because this project is based on https://flake.parts, never add `specialArgs = { inherit pkgs; };` or similar to any `modules/**/*.nix` files.
