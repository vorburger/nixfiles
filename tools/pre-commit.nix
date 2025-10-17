{ inputs, lib, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    {
      self',
      pkgs,
      config,
      ...
    }:
    {
      pre-commit.settings.hooks.nix-fmt = {
        enable = true;
        entry = lib.getExe self'.formatter;
      };
      # TODO Why is 'pre-commit' still not on PATH inside "nix devshell" ?!
      devShells.default = pkgs.mkShell {
        shellHook = "${config.pre-commit.shellHook}";
        packages = config.pre-commit.settings.enabledPackages;
      };
    };
}
