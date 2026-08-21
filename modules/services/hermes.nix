# Hermes Agent - AI agent framework by Nous Research
# See https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup#nixos-module
{ inputs, ... }:
{
  flake-file.inputs.hermes-agent = {
    url = "github:NousResearch/hermes-agent";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
      home-manager.follows = "home-manager";
    };
  };

  flake.nixosModules = {
    hermes =
      { ... }:
      {
        imports = [
          inputs.hermes-agent.nixosModules.default
        ];
      };
    hermes-agent =
      { ... }:
      {
        imports = [
          inputs.hermes-agent.nixosModules.default
        ];
      };
  };
}
