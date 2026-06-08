{ inputs, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";
  flake-file.inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  flake-file.inputs.home-manager-stable.url = "github:nix-community/home-manager/release-26.05";
  flake-file.inputs.home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
