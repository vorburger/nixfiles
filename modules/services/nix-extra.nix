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

      # https://nixos.org/manual/nixos/stable/#sec-nix-gc
      # systemctl status nix-gc.timer && systemctl status nix-gc.service
      # nix-collect-garbage
      nix.gc.automatic = true;
    };
  };
}
