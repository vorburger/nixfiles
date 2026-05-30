{ inputs, ... }:
{
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
}
