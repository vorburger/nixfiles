# NixOS Channels & Home Manager Versioning

This repo runs some hosts on a **stable** NixOS channel (for ZFS production reliability)
but other hosts on _"bleeding edge"_ `nixos-unstable`. Here is a TL;DR of how the pieces fit
together, and what to do when bumping channels.

## How it works

| File                             | What it controls                                                          |
| -------------------------------- | ------------------------------------------------------------------------- |
| `modules/tools/flake-file.nix`   | Declares the `nixpkgs` and `nixpkgs-stable` input URLs                    |
| `modules/tools/home-manager.nix` | Declares the `home-manager` input URL                                     |
| `lib/mk-host.nix`                | `mkHost` accepts an optional `nixpkgs` arg (defaults to `inputs.nixpkgs`) |
| `modules/hosts/titan.nix`        | Passes `nixpkgs = inputs.nixpkgs-stable` to `mkHost`                      |

`mkHost` uses the given `nixpkgs` both for `nixpkgs.lib.nixosSystem` and for the
VM boot test (via `mk-test.nix`), so the test VM uses the same channel as the
production system.

## The home-manager version trap ⚠️

`home-manager` has its own version string (e.g. `26.05`, `26.11`) that it checks
against the `system.nixos.release` of the host. If they mismatch, it emits a
**warning** — which with `abort-on-warn = true` in `nixConfig` becomes a **hard
error** that blocks `nix flake check`.

The trap: home-manager's _master_ branch bumps its version string ahead of the
current NixOS release cycle. For example, right after NixOS `26.05` was released,
master already said `26.11`, while both `nixos-unstable` and `nixos-26.05` still
reported `system.nixos.release = "26.05"`.

**Fix:** pin `home-manager` to the matching release branch in
`modules/tools/home-manager.nix`:

```nix
flake-file.inputs.home-manager.url = "github:nix-community/home-manager/release-26.05";
```

## Checklist: bumping `nixpkgs-stable` to the next release

Say you want to move `titan` from `nixos-26.05` to `nixos-26.11`:

1. **Update the stable channel URL** in
   `modules/tools/flake-file.nix`:

   ```nix
   nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.11";
   ```

2. **Regenerate `flake.nix`** (it is auto-generated — do not edit it directly):

   ```bash
   nix run .#write-flake
   ```

3. **Update the home-manager pin** in
   `modules/tools/home-manager.nix` to
   the matching release branch:

   ```nix
   flake-file.inputs.home-manager.url = "github:nix-community/home-manager/release-26.11";
   ```

   Run `nix run .#write-flake` again afterwards.

4. **Update the lock file:**

   ```bash
   nix flake update nixpkgs-stable home-manager
   ```

5. **Verify:**

   ```bash
   nix flake check
   ```

   Look out for any `Home Manager version X.Y and Nixpkgs version X.Z` warnings —
   they indicate the home-manager pin and the nixpkgs channel are still out of
   sync.

## Why two downloads?

`nixpkgs` (unstable) and `nixpkgs-stable` are separate Nix store paths. Any
package that appears in both channels will be fetched and stored twice. This is
expected and unavoidable when mixing channels. The trade-off is: production
stability on `titan` in exchange for some extra disk space.
