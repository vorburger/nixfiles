{ inputs, lib, ... }:
{
  systems = lib.mkDefault (import inputs.systems);
}
