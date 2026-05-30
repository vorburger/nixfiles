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
      import-tree.url = "github:vic/import-tree";
    };
    nixConfig = {
      abort-on-warn = true;
    };
    description = "Nix files of https://www.vorburger.ch";
  };
}
