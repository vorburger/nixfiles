{ inputs, ... }:
{
  imports = [
    ./_dendritic-local.nix
    (inputs.flake-file + "/modules/dendritic/basic.nix")
    (inputs.flake-file + "/modules/dendritic/nixpkgs.nix")
  ];
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
      flake-parts.url = "github:hercules-ci/flake-parts";
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
      import-tree.url = "github:vic/import-tree";
    };
    nixConfig = {
      abort-on-warn = true;
    };
    description = "Nix files of https://www.vorburger.ch";
  };
}
