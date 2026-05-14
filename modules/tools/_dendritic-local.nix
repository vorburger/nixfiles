{ inputs, lib, ... }:
{
  # See https://github.com/denful/flake-file/issues/115
  # This is a local copy of (inputs.flake-file + "/modules/dendritic/dendritic.nix")
  # but with 'flake.modules = { };' and 'flake-parts.flakeModules.modules' removed
  # to fix the "unknown flake output 'modules'" warning from nix flake check.

  imports = [
    (inputs.flake-file.flakeModules.import-tree or { })
  ];

  flake-file.inputs = {
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = lib.mkDefault "nixpkgs";
  };

  flake-file.outputs = lib.mkDefault "dendritic";
}
