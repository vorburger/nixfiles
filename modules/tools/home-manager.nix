{ inputs, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
