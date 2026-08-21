# Nix for Agents

- Whenever there are any formatting errors, just run `nix fmt`.
- After making any and for each change to `*.nix` files, always execute `nix develop --command nix-fast-build --fail-fast --flake .#checks.x86_64-linux` to run various tests which verify everything is OK. It stops immediately on the first error (fail-fast) while still building in parallel. To instead see all errors at once, use `nix develop --command nix-fast-build --flake .#checks.x86_64-linux`.
- Because this project is based on https://flake.parts, never add `specialArgs = { inherit pkgs; };` or similar to any `modules/**/*.nix` files.
- When committing files, do not use prefixes like "fix(nixos):". Instead, start the message with the action taken.
- There is no NixOS `x88_64` "system" (CPU type), it's a LLM-generated typo mistake; use `x86_64-linux` instead.
- Because this project uses https://github.com/vic/import-tree, the `flake.nix` always has **ALL** `modules/**/*.nix` files.
  So there is never any need to manually edit `fake.nix` to add or remove any `*.nix` files.

- Whenever making changes to `*.nix` files, check if there is any related documentation under `docs/` that needs to be updated to match the changes.
- All documentation Markdown files must be created inside `docs/docs/` (e.g., `docs/docs/reference/*.md`), NOT in the `docs/` root directory. When adding new documentation pages, always register them under the `nav:` section in `docs/mkdocs.yaml`.

- If Nix is missing in the environment, install it using:
  `curl -L https://raw.github.com/vorburger/aifiles/main/skills/install-nix/scripts/install-nix.sh | sh && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`

- **Flake Inputs & Follows**:
  - Always declare new flake inputs in the appropriate `modules/**/*.nix` file using `flake-file.inputs.<name> = { url = "..."; ... };` instead of editing `flake.nix` directly. Running `nix run .#write-flake` will auto-generate `flake.nix`.
  - Always override sub-dependencies (like `nixpkgs`, `home-manager`, `systems`) in flake inputs with `inputs.<dep>.follows = "<dep>";` to prevent duplicate lockfile dependencies and keep builds lean.

- **Adding Services**:
  - Always define new services in `modules/services/<name>.nix` using `mkService` (from `../../lib/mk-service.nix`), exporting `flake.nixosModules.<name> = mkService { name = "<name>"; ... };`.
  - Always register the new module in `modules/hosts/_common.nix` under `imports = [ self.nixosModules.<name> ... ]`.
  - Service naming convention: If there is an existing standard NixOS service with that name, use `<name>-extra` (e.g. `caddy-extra`, `fprintd-extra`); otherwise name it directly `<name>` (e.g. `backup`, `smart`, `hello`, `hermes`).
  - Enable services only on the specific host configurations that require them (e.g., `services.<name>.enable = true;` in `modules/hosts/titan.nix`), rather than enabling them globally on all hosts.

- **Secrets Management**:
  - Never put API keys, passwords, or tokens directly in Nix files, system files, or unencrypted `.env` files in state directories.
  - Always use `mkSecret` (from `../../lib/mk-secret.nix`) in the service module to manage secrets encrypted with `ragenix` (`secrets/encrypted/<name>.age`).
  - Merge the secret into the service module so that `age.secrets.<name>` is only enabled when `services.<name>.enable = true`.
  - Pass secrets to services using the runtime decrypted path at `/run/secrets/<name>`.
