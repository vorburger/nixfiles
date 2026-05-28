{ ... }:
{
  flake-file.inputs.antigravity.url = "github:jacopone/antigravity-nix";
  flake-file.inputs.antigravity.inputs.nixpkgs.follows = "nixpkgs";
  # TODO flake-file.inputs.antigravity.inputs.flake-utils.follows = "flake-utils";

  imports = [ ];
}
