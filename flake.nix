# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Nix files of https://www.vorburger.ch";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    auto-follow.url = "github:fzakaria/nix-auto-follow";
    devshell.url = "github:numtide/devshell";
    disko.url = "github:nix-community/disko";
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    git-hooks.url = "github:cachix/git-hooks.nix";
    home-manager.url = "github:nix-community/home-manager";
    import-tree.url = "github:vic/import-tree";
    mkdocs-flake.url = "github:applicative-systems/mkdocs-flake";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    vorburger-dotfiles.url = "github:vorburger/vorburger-dotfiles-bin-etc?dir=dotfiles/home-manager";
  };

}
