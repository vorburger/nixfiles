let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.smart = mkService {
    name = "smart";
    description = "SMART stuff";
    content =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.smartmontools
          # TODO Only install gsmartcontrol IFF on UI host...
          pkgs.gsmartcontrol
        ];
      };
  };
}
