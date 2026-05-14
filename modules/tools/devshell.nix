{ inputs, ... }:
{
  flake-file.inputs.devshell.url = "github:numtide/devshell";
  flake-file.inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  imports = [
    inputs.devshell.flakeModule
  ];
}
