{ ... }:
{
  flake-file.inputs.antigravity.url = "github:jacopone/antigravity-nix";
  flake-file.inputs.antigravity.inputs.nixpkgs.follows = "nixpkgs";

  imports = [ ];
}
