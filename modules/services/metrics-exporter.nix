{
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.metrics-exporter = mkService {
    name = "metrics-exporter";
    description = "Prometheus node and SMART metrics exporters";
    extraOptions = {
      smartctlDevices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of devices to monitor with smartctl exporter, e.g. [\"/dev/nvme0n1\"]. If empty, smartctl-exporter auto-detects devices.";
      };
    };
    content =
      { selfCfg, ... }:
      {
        services.prometheus.exporters = {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
          };
          smartctl = {
            enable = true;
            devices = selfCfg.smartctlDevices;
          };
        };
      };
  };
}
