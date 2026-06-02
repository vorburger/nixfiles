{
  flake.nixosModules.personality-console =
    { ... }:
    {
      imports = [ ../../users/_tester.nix ];
    };
}
