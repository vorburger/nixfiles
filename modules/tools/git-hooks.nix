{ inputs, lib, ... }:
{
  flake-file.inputs.git-hooks.url = "github:cachix/git-hooks.nix";

  imports = [
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    {
      self',
      ...
    }:
    {
      # Alternative: https://github.com/j178/prek instead of https://pre-commit.com
      pre-commit.settings.hooks.nix-fmt = {
        enable = true;
        entry = lib.getExe self'.formatter;
      };
      # TODO Make 'pre-commit' available on PATH inside "nix devshell"...
      # devshells.default = {
      #   devshell.packages = [ config.pre-commit.settings.enabledPackages ];
      # };
      ## devShells.default = pkgs.mkShell {
      ##  shellHook = "${config.pre-commit.shellHook}";
      ##  packages = config.pre-commit.settings.enabledPackages;
      #};
    };
}
