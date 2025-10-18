{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = [ pkgs.nixos-rebuild ];
      };
    };
}
