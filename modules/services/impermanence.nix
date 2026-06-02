let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.impermanence =
    { ... }:
    {
      imports = [
        (mkService {
          name = "impermanence";
          description = "impermanence configuration";
          content = {
            # TODO https://github.com/nix-community/preservation, see https://www.vimjoyer.com/vid89-impermanent
          };
        })
      ];

      users.mutableUsers = false;
    };
}
