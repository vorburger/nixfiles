{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = [
          pkgs.nix-output-monitor
          pkgs.pkgs.nix-fast-build
          pkgs.nixos-anywhere
          pkgs.nixos-install-tools
          pkgs.nixos-rebuild
        ];
      };
    };
}
