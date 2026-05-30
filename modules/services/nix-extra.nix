let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.nix-extra = mkService {
    name = "nix-extra";
    description = "extra Nix configuration (flakes, etc.)";
    content = {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # systemctl status nix-gc.service
      nix.gc.automatic = true;
    };
  };
}
