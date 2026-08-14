# This module exposes the Google Antigravity package from github:Hy4ri/antigravity-flake.
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      packages.antigravity = inputs.antigravity.packages.${system}.antigravity;
    };
}
