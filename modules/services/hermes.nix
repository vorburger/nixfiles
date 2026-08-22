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
            model_aliases = {
              gemma = {
                model = "gemma4:e2b";
                provider = "custom";
                base_url = "http://localhost:11434/v1";
              };
              gemini = {
                model = "gemini-flash-latest";
                provider = "gemini";
                base_url = "https://generativelanguage.googleapis.com/v1beta";
              };
            };
            display = {
              interface = "tui";
              compact = true;
              tui_statusbar = "off";
              cli_refresh_interval = 0;
              resume_display = "minimal";
            };
            approvals = {
              destructive_slash_confirm = false;
            };
            auxiliary = {
              title_generation = {
                extra_body = {
                  thinking_config = {
                    thinking_budget = 0;
                  };
                };
              };
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

        # Export HERMES_HOME and alias h for fish interactive shells and desktop environment
        programs.fish.interactiveShellInit = ''
          set -gx HERMES_HOME /var/lib/hermes/.hermes
          alias h=hermes
        '';

        environment.sessionVariables = {
          HERMES_HOME = "/var/lib/hermes/.hermes";
        };
      };
  };
}
