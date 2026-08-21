let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  inherit (import ../../lib/mk-service.nix) mkService;
  secret = mkSecret {
    name = "hermes";
    moduleName = "hermes";
    mode = "0440";
    owner = "hermes";
    group = "hermes";
  };
in
{
  inputs,
  lib,
  ...
}:
lib.recursiveUpdate secret {
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
    content =
      _:
      lib.recursiveUpdate secret.flake.nixosModules.hermes {
        services.hermes-agent = {
          enable = true;
          addToSystemPackages = true;
          settings = {
            model = {
              default = "gemini-flash-latest";
              provider = "gemini";
              base_url = "https://generativelanguage.googleapis.com/v1beta";
            };
            display = {
              interface = "tui";
            };
          };
          environmentFiles = [
            "/run/secrets/hermes"
          ];
        };

        # Allow user vorburger to access hermes state directory and group
        users.users.vorburger.extraGroups = [ "hermes" ];

        # Ensure hermes-agent-setup runs AFTER ragenix has decrypted /run/secrets/hermes
        system.activationScripts.hermes-agent-setup.deps = [
          "agenixInstall"
          "agenixChown"
        ];

        # Export HERMES_HOME for fish interactive shells and desktop environment
        programs.fish.interactiveShellInit = ''
          set -gx HERMES_HOME /var/lib/hermes/.hermes
        '';

        environment.sessionVariables = {
          HERMES_HOME = "/var/lib/hermes/.hermes";
        };
      };
  };
}
