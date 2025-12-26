{ inputs, ... }:
{
  flake-file.inputs.home-manager.url = "github:nix-community/home-manager";

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
