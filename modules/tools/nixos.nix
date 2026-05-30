{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = [
          pkgs.nixos-anywhere
          pkgs.nixos-install-tools
          pkgs.nixos-rebuild
        ];
      };
    };
}
