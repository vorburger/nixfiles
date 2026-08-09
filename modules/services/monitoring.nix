let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
  inherit (import ../../lib/mk-service.nix) mkService;
  secret = mkSecret {
    name = "grafana";
    moduleName = "monitoring";
    mode = "0440";
    group = "grafana";
  };
in
{ lib, ... }:
lib.recursiveUpdate secret {
  flake.nixosModules.monitoring = mkService {
    name = "monitoring";
    description = "Prometheus server and Grafana monitoring stack";
    content =
      { pkgs, ... }:
      let
        fixDashboard =
          src:
          pkgs.runCommand "fixed-dashboard.json" { } ''
            ${pkgs.gnused}/bin/sed 's/''${DS_[^}]*}/Prometheus/g' ${src} > $out
          '';
      in
      lib.recursiveUpdate secret.flake.nixosModules.monitoring {
        services.prometheus = {
          enable = true;
          port = 9090;
          listenAddress = "127.0.0.1";
          scrapeConfigs = [
            {
              job_name = "node";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9100" ];
                }
              ];
            }
            {
              job_name = "smartctl";
              static_configs = [
                {
                  targets = [ "127.0.0.1:9633" ];
                }
              ];
            }
          ];
        };

        services.grafana = {
          enable = true;
          settings = {
            server = {
              http_addr = "127.0.0.1";
              http_port = 3000;
            };
            security = {
              secret_key = "$__file{/run/secrets/grafana}";
            };
          };
          provision = {
            enable = true;
            datasources.settings.datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                url = "http://127.0.0.1:9090";
                isDefault = true;
              }
            ];
            dashboards.settings.providers = [
              {
                name = "default";
                options.path = pkgs.linkFarm "grafana-dashboards" [
                  {
                    name = "node-exporter-full.json";
                    path = fixDashboard (
                      pkgs.fetchurl {
                        url = "https://grafana.com/api/dashboards/1860/revisions/45/download";
                        hash = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
                      }
                    );
                  }
                  {
                    name = "smart-disk-monitoring.json";
                    path = fixDashboard (
                      pkgs.fetchurl {
                        url = "https://grafana.com/api/dashboards/20204/revisions/1/download";
                        hash = "sha256-2/JP+1OXQMnucpuxuiN4p8gM22bsDnJtHQDpgJ4lmXc=";
                      }
                    );
                  }
                ];
              }
            ];
          };
        };
      };
  };
}
