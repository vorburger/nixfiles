{ inputs, lib, ... }:
{
  flake-file.inputs.systems.url = "github:nix-systems/default";

  systems = lib.mkDefault (import inputs.systems);
}
