_:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  #  zramctl shows if this is activated
  flake.nixosModules.zram = mkService {
    name = "zram";
    description = "Zram Swap";
    content = {
      zramSwap.enable = true;

      boot.kernel.sysctl = {
        # Default is usually 60; 100 encourages aggressive use of zram for stale pages
        "vm.swappiness" = 100;
      };
    };
  };
}
