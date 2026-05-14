let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.initial-secrets = mkService {
    name = "initial-secrets";
    description = "initial secrets handling";
    extraOptions =
      { lib, ... }:
      {
        users = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ "vorburger" ];
          description = "List of users for whom to enable hashedPasswordFile in /etc/secrets/<username>-password";
        };
      };
    content =
      { cfg, lib, ... }:
      {
        users.users = lib.genAttrs cfg.users (name: {
          hashedPasswordFile = "/etc/secrets/${name}-password";
        });
      };
  };
}
