{ lib, ... }:
{
  options.flake.secretRules = lib.mkOption {
    type = lib.types.functionTo (lib.types.attrsOf lib.types.anything);
    default = _recipients: { };
    description = "Functions mapping recipients to age secret public keys";
  };
}
