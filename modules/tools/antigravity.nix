{ ... }:
{
  flake-file.inputs.antigravity.url = "github:Hy4ri/antigravity-flake";
  flake-file.inputs.antigravity.inputs.nixpkgs.follows = "nixpkgs";

  imports = [ ];
}
