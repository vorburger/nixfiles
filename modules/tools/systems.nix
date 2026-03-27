{ inputs, lib, ... }:
{
  flake-file.inputs.systems.url = "path:./nix-systems.nix";

  systems = lib.mkDefault (import inputs.systems);
}
