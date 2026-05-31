{ inputs, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager/release-26.05";
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
