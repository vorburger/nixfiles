{
  perSystem =
    { pkgs, ... }:
    let
      h = pkgs.writeShellApplication {
        name = "h";
        text = ''
          echo "hello, world"
        '';
      };
    in
    {
      packages.h = h;

      checks.h = h;

      devshells.default = {
        devshell.packages = [ h ];
      };
    };
}
