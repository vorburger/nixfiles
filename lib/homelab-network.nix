# Homelab Network Configuration
# Single source of truth for hostnames, LAN IPs, WireGuard IPs, and public keys.
{
  domain = "home.vorburger.ch";
  serverEndpoint = "vinea.internet-box.ch:51820";
  port = 51820;

  subnets = {
    ipv4 = "10.25.75.0/24";
    ipv6 = "fd25:75::/64";
  };

  # Host definitions across the homelab network
  hosts = {
    titan = {
      role = "server";
      lanIpv4 = "192.168.1.99";
      wireguardIpv4 = "10.25.75.1";
      wireguardIpv6 = "fd25:75::1";
      publicKey = "UVdA/6vjg/5mq+re3rnKzWUJvdqCPC/ObHQSFTUDqDg=";
      trusted = true;
    };

    ixo = {
      role = "client";
      wireguardIpv4 = "10.25.75.2";
      wireguardIpv6 = "fd25:75::2";
      publicKey = "vkzl9tUdw+9EZdClKirFaygTVo5C2PqjPs9DJ8MuqhI=";
      trusted = true; # Admin workstation: full access to SSH (22), Caddy, metrics, etc.
    };

    # Template for future clients (e.g. tablet):
    # tablet = {
    #   role = "client";
    #   wireguardIpv4 = "10.25.75.3";
    #   wireguardIpv6 = "fd25:75::3";
    #   publicKey = "...";
    #   trusted = false; # Media client: restricted to HTTP (80) & HTTPS (443) for Vorbflix/Caddy
    # };
  };
}
