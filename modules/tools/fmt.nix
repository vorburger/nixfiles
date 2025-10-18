# Thank You https://github.com/drupol/infra/blob/096748d4e4badffcc86f63b18d3ebe0618ee6a17/modules/flake-parts/fmt.nix
{ inputs, ... }:
{
  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          deadnix.enable = true;
          nixfmt.enable = true;
          prettier.enable = true;
          shfmt.enable = true;
          statix.enable = true;
          taplo.enable = true;
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
          formatter.sh = {
            command = "${pkgs.shfmt}/bin/shfmt";
            options = [
              "-i"
              "2"
              "-s"
            ];
            includes = [
              "*.sh"
              "bin/vm"
            ];
          };
        };
      };
    };
}
