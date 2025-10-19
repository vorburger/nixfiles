{ inputs, ... }:
{
  flake-file.inputs.mkdocs-flake.url = "github:applicative-systems/mkdocs-flake";

  imports = [
    # inputs.mkdocs-flake.flakeModuleabort
    inputs.mkdocs-flake.flakeModules.default
  ];

  perSystem = {
    documentation.mkdocs-root = ../../docs;
    documentation.strict = true;
  };
}
