{ inputs, ... }:
{
  flake-file.inputs.git-hooks.url = "github:cachix/git-hooks.nix";
  flake-file.inputs.git-hooks.inputs.nixpkgs.follows = "nixpkgs";

  imports = [
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    {
      pkgs,
      self',
      config,
      ...
    }:
    {
      # Alternative: https://github.com/j178/prek instead of https://pre-commit.com
      pre-commit.settings.hooks.treefmt = {
        enable = true;
        package = self'.formatter;
      };

      devshells.default = {
        devshell.packages = [ pkgs.pre-commit ] ++ config.pre-commit.settings.enabledPackages;
        devshell.startup.pre-commit.text = config.pre-commit.installationScript;
      };
    };
}
