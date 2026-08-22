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
      { pkgs, ... }:
      let
        rtk-hermes = pkgs.python3Packages.buildPythonPackage rec {
          pname = "rtk-hermes";
          version = "1.2.3";
          pyproject = true;
          src = pkgs.fetchFromGitHub {
            owner = "ogallotti";
            repo = "rtk-hermes";
            rev = "v${version}";
            hash = "sha256-7YRW6PODrCapfYLFn3DvgHAEME//RGC48GQt+s9ot0s=";
          };
          build-system = with pkgs.python3Packages; [
            setuptools
            wheel
          ];
        };

        hermes-lcm = pkgs.fetchFromGitHub {
          owner = "stephenschoettler";
          repo = "hermes-lcm";
          rev = "v0.21.0-rc2";
          hash = "sha256-EtrrGsmsnDUsGv76pUlKlXsqyAnja53avmsNGb3dsdg=";
        };
      in
      lib.recursiveUpdate secret.flake.nixosModules.hermes {
        services.hermes-agent = {
          enable = true;
          addToSystemPackages = true;
          extraPackages = [
            pkgs.rtk
          ];
          extraPythonPackages = [
            rtk-hermes
            pkgs.python3Packages.tiktoken
            pkgs.python3Packages.regex
          ];
          extraPlugins = [
            hermes-lcm
          ];
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
            plugins = {
              enabled = [
                "rtk-rewrite"
                "hermes-lcm"
              ];
            };
            context = {
              engine = "lcm";
            };
            # Unused as long as context.engine = "lcm" is active, but kept as a fallback if LCM is ever disabled
            compression = {
              enabled = true;
              threshold = 0.50;
              target_ratio = 0.20;
              protect_last_n = 20;
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
            # TODO Remove when https://github.com/NousResearch/hermes-agent/issues/91927 is fixed:
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
