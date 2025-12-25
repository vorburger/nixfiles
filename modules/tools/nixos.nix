{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = [
          pkgs.nixos-install-tools
          pkgs.nixos-rebuild
        ];
      };
    };
}
