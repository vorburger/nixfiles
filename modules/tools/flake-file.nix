{ inputs, ... }:
{
  flake-file.inputs.flake-file.url = "github:vic/flake-file";

  imports = [
    # TODO .import-tree
    inputs.flake-file.flakeModules.default
  ];
  flake-file = {
    inputs = {
      flake-parts.url = "github:hercules-ci/flake-parts";
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      import-tree.url = "github:vic/import-tree";
    };
    nixConfig = { };
    description = "Nix files of https://www.vorburger.ch";
  };
}
