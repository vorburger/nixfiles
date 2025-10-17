{
  description = "Nix files of https://www.vorburger.ch";

  inputs = {
    # ALWAYS run "auto-follow -i" AFTER adding inputs and running `nix flake check`
    # TODO Automate this...
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    auto-follow.url = "github:fzakaria/nix-auto-follow";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

        inputs.devshell.flakeModule
        ./tools/fmt.nix
        ./tools/pre-commit.nix
        ./tools/auto-follow.nix
        ./demo/hello.nix
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        _:
        {
        };
      flake =
        _:
        {
        };
    };
}
