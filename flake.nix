{
  description = "Nix files of https://www.vorburger.ch";

  inputs = {
    # ALWAYS run "auto-follow -i" AFTER adding inputs and running `nix flake check`
    # TODO Automate this...
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    auto-follow.url = "github:fzakaria/nix-auto-follow";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./tools/systems.nix
        ./tools/devshell.nix
        ./tools/fmt.nix
        ./tools/pre-commit.nix
        ./tools/auto-follow.nix
        ./demo/hello.nix
      ];
    };
}
