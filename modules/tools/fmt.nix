# Thank You https://github.com/drupol/infra/blob/096748d4e4badffcc86f63b18d3ebe0618ee6a17/modules/flake-parts/fmt.nix
{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = _: {
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
  };
}
