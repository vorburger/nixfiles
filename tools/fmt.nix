# Thank You https://github.com/drupol/infra/blob/096748d4e4badffcc86f63b18d3ebe0618ee6a17/modules/flake-parts/fmt.nix
{ inputs, lib, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    { self', ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          prettier.enable = true;
          shfmt.enable = true;
          statix.enable = true;
          yamlfmt.enable = true;
        };
        settings = {
          on-unmatched = "fatal";
          global.excludes = [
            "*.envrc"
            ".editorconfig"
            "*.fish"
            "*/.gitignore"
            "LICENSE"
          ];
        };
      };

      pre-commit.settings.hooks.nix-fmt = {
        enable = true;
        entry = lib.getExe self'.formatter;
      };
    };
}
