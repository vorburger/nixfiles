{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  # Replaces NixOS's default stub-ld shim to execute unpatched dynamic ELF binaries.
  # See https://nix.dev/permalink/stub-ld and docs/reference/nix-ld.md
  flake.nixosModules.nix-ld = mkService {
    name = "nix-ld";
    description = "nix-ld to run unpatched dynamic binaries on NixOS";
    extraOptions = {
      libraries = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional libraries to provide to dynamic binaries via nix-ld.";
      };
    };
    content =
      { cfg, pkgs, ... }:
      {
        programs.nix-ld = {
          enable = true;
          libraries =
            with pkgs;
            [
              stdenv.cc.cc.lib
              zlib
              ncurses
              ncurses5
              libxcrypt-legacy
              libaio
              liburing
            ]
            ++ cfg.libraries;
        };
      };
  };
}
