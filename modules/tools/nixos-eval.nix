# Adds eval-only checks for all nixosConfigurations, so that
# "nix-fast-build --flake .#checks.x86_64-linux" catches the same evaluation
# errors as "nix flake check" (conflicting options, assertion failures, etc.)
# without actually building the full NixOS system toplevels.
#
# Checking system.activationScripts verifies the bash syntax of all activation
# script fragments without pulling in the entire toplevel OS closure.
# Discarding the string context on toplevel.drvPath forces full NixOS evaluation
# without adding toplevel as a build dependency.
{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks = builtins.mapAttrs (
        name: cfg:
        let
          actScript = pkgs.writeText "activation-script-${name}" (
            builtins.unsafeDiscardStringContext cfg.config.system.activationScripts.script
          );
          drvPath = builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath;
        in
        pkgs.runCommand "nixos-eval-${name}" { } ''
          ${pkgs.bash}/bin/bash -n "${actScript}"
          echo "${drvPath}" > $out
        ''
      ) self.nixosConfigurations;
    };
}
