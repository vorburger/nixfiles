let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.nix-extra = mkService {
    name = "nix-extra";
    description = "extra Nix configuration (flakes, etc.)";
    content =
      {
        inputs,
        lib,
        options,
        pkgs,
        ...
      }:
      {
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        # https://nixos.org/manual/nixos/stable/#sec-nix-gc
        # systemctl status nix-gc.timer && systemctl status nix-gc.service
        # nix-collect-garbage
        nix.gc.automatic = true;
        nix.gc.options = "--delete-older-than 30d";

        environment.systemPackages = [
          pkgs.dix # https://github.com/manic-systems/dix
          pkgs.nh # https://github.com/nix-community/nh
          pkgs.nix-output-monitor
          inputs.nix-fast-build.packages.${pkgs.stdenv.hostPlatform.system}.nix-fast-build
        ];

        # Required, for now; e.g. for Visual Studio Code (VSC)
        nixpkgs.config = lib.mkIf (!options.nixpkgs.pkgs.isDefined) {
          allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) (import ../../lib/unfree-packages.nix);
        };
      };
  };
}
