# Nix for Agents

- Whenever there are any formatting errors, just run `nix fmt`.
- After making any and for each change to `*.nix` files, always execute `nix develop --command scripts/nix-fast-build-fail-fast.sh --flake .#checks.x86_64-linux` to run various tests which verify everything is OK. It stops immediately on the first error (fail-fast) while still building in parallel. To instead see all errors at once, use `nix develop --command nix-fast-build --flake .#checks.x86_64-linux`.
- Because this project is based on https://flake.parts, never add `specialArgs = { inherit pkgs; };` or similar to any `modules/**/*.nix` files.
- When committing files, do not use prefixes like "fix(nixos):". Instead, start the message with the action taken.
- There is no NixOS `x88_64` "system" (CPU type), it's a LLM-generated typo mistake; use `x86_64-linux` instead.
- Because this project uses https://github.com/vic/import-tree, the `flake.nix` always has **ALL** `modules/**/*.nix` files.
  So there is never any need to manually edit `fake.nix` to add or remove any `*.nix` files.

- If Nix is missing in the environment, install it using:
  `curl -L https://raw.github.com/vorburger/aifiles/main/skills/install-nix/scripts/install-nix.sh | sh && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`
