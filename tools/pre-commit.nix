{ inputs, lib, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    { self', ... }:
    {
      pre-commit.settings.hooks.nix-fmt = {
        enable = true;
        entry = lib.getExe self'.formatter;
      };
    };
}
