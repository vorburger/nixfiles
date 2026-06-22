{
  pkgs,
  ...
}:
let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.printing-extra = mkService {
    name = "printing-extra";
    description = "Printers support (CUPS)";
    content = {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          # brlaser
          # gutenprint
          # hplip
        ];
      };

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
