{ config, lib, ... }:
let
  cfg = config.services.initial-secrets;
in
{
  # This module provides a way to handle initial secrets (like user passwords)
  # without committing them to git. It expects these secrets to be provided at runtime,
  # for example via nixos-anywhere's --extra-files flag.
  #
  # Convention:
  # - User passwords are at /etc/secrets/<username>-password (hashed)
  # - WiFi profiles are at /etc/NetworkManager/system-connections/<SSID>.nmconnection
  #
  # For NetworkManager to pick up secrets from files in /etc/NetworkManager/system-connections/,
  # we don't necessarily need Nix configuration for the specific profiles,
  # but we MUST ensure NetworkManager is enabled (which it is in _networking.nix).

  options.services.initial-secrets = {
    enable = lib.mkEnableOption "initial secrets handling";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "vorburger" ];
      description = "List of users for whom to enable hashedPasswordFile in /etc/secrets/<username>-password";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.genAttrs cfg.users (name: {
      hashedPasswordFile = "/etc/secrets/${name}-password";
    });
  };
}
