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

      # Open ports in the firewall? (See openssh-extra.nix for an example.)
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    };
  };
}
