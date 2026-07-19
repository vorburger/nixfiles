{ inputs, ... }:
{
  # 1. Flake Evaluation Context Configuration (perSystem):
  # Sets allowUnfreePredicate for _module.args.pkgs at the flake-parts level.
  # This is required so that flake-level actions, checks, and VM/host builder
  # evaluations that reference unfree packages (defined in lib/unfree-packages.nix)
  # do not fail during evaluation.
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate =
            pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) (import ../../lib/unfree-packages.nix);
        };
      };
    };

  # 2. NixOS Host System Configuration (flake.nixosModules.unfree):
  # Defines a NixOS module imported by target hosts (usually via modules/hosts/_common.nix).
  # This configures nixpkgs.config.allowUnfreePredicate on the target NixOS systems,
  # allowing unfree packages to be installed on those systems.
  flake.nixosModules.unfree =
    { lib, options, ... }:
    {
      nixpkgs.config = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) (import ../../lib/unfree-packages.nix);
      };
    };
}
