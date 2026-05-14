{ ... }:
{
  flake-file.inputs.disko.url = "github:nix-community/disko";
  flake-file.inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  imports = [
    # inputs.disko.flakeModules.default
  ];
}
