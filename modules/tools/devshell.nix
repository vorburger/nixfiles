{ inputs, ... }:
{
  flake-file.inputs.devshell.url = "github:numtide/devshell";

  imports = [
    inputs.devshell.flakeModule
  ];
}
