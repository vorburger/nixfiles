{ inputs, ... }:
{
  imports = [
    (inputs.flake-file + "/modules/dendritic/dendritic.nix")
    (inputs.flake-file + "/modules/dendritic/basic.nix")
    (inputs.flake-file + "/modules/dendritic/nixpkgs.nix")
  ];
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
      flake-parts.url = "github:hercules-ci/flake-parts";
      nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
      import-tree.url = "github:vic/import-tree";
    };
    nixConfig = { };
    description = "Nix files of https://www.vorburger.ch";
  };
}
