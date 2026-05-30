{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = [
          pkgs.nh # https://github.com/nix-community/nh
          pkgs.nix-output-monitor
          pkgs.nix-fast-build
          pkgs.nixos-anywhere
          pkgs.nixos-install-tools
          pkgs.nixos-rebuild
        ];
      };
    };
}
