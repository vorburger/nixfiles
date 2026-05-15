{
  flake.nixosModules.personality-console =
    { ... }:
    {
      imports = [ ../../users/_tester.nix ];

      system.stateVersion = "25.05";
    };
}
