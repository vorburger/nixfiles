let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.networking-extra = mkService {
    name = "networking-extra";
    description = "extra networking configuration (NetworkManager)";
    content = {
      # TODO Laptops: networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      networking.networkmanager.enable = true;
      systemd.services.NetworkManager-wait-online.enable = true;
    };
  };
}
