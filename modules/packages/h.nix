{
  perSystem =
    { pkgs, ... }:
    let
      h = pkgs.writeShellApplication {
        name = "h";
        text = ''
          echo "hello, world"
          if [ -f /run/secrets/hello-secret ]; then
            cat /run/secrets/hello-secret
            echo ""
          fi
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
