let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.samba-extra = mkService {
    name = "samba-extra";
    description = "Samba extra configuration for /nas/public";
    content = {
      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "smbnix";
            "netbios name" = "smbnix";
            "security" = "user";
            "guest account" = "nobody";
            "map to guest" = "bad user";
          };
          public = {
            "path" = "/nas/public";
            "public" = "yes";
            "only guest" = "yes";
            "writable" = "yes";
            "printable" = "no";
          };
        };
      };
    };
  };
}
