# Adds eval-only checks for all nixosConfigurations, so that
# "nix-fast-build --flake .#checks.x86_64-linux" catches the same evaluation
# errors as "nix flake check" (conflicting options, assertion failures, etc.)
# without actually building the full NixOS system toplevels.
#
# The string interpolation of a derivation resolves to its output store path,
# which only requires evaluation (not building). So writeText forces a full
# config eval but the resulting derivation is trivially small and fast to build.
{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = builtins.mapAttrs (
        name: cfg:
        let
          toplevel = cfg.config.system.build.toplevel;
        in
        pkgs.runCommand "nixos-eval-${name}" { } ''
          echo "${toplevel}"
          ${pkgs.bash}/bin/bash -n "${toplevel}/activate"
          touch $out
        ''
      ) self.nixosConfigurations;
    };
}
