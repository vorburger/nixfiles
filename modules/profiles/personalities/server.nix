{ lib, ... }:
{
  flake.nixosModules.personality-server = _: {
    # Servers should not use temporary/rotating IPv6 privacy addresses (RFC 4941),
    # because incoming services (SSH, WireGuard, Caddy, Transmission, etc.) rely on
    # a stable, predictable IPv6 address for firewall rules, router pinholes, and DNS.
    networking.tempAddresses = lib.mkDefault "disabled";
  };
}
