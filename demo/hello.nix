{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = [ pkgs.hello ];
      };
    };
}
