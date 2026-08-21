let
  inherit (import ../../lib/mk-service.nix) mkService;
in
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

  flake.nixosModules.hermes = mkService {
    name = "hermes";
    description = "Hermes Agent AI framework";
    imports = [
      inputs.hermes-agent.nixosModules.default
    ];
    content = {
      services.hermes-agent = {
        enable = true;
        addToSystemPackages = true;
      };
    };
  };
}
