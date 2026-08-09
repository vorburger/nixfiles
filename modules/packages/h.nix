let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
in
mkSecret {
  name = "hello";
  moduleName = "h";
  mode = "0444";
}
// {
  perSystem =
    { pkgs, ... }:
    let
      h = pkgs.writeShellApplication {
        name = "h";
        text = ''
          echo "hello, world"
          if [ -f /run/secrets/hello ]; then
            cat /run/secrets/hello
            echo ""
          else
            echo "MISSING /run/secrets/hello"
          fi
        '';
      };
    in
    {
      packages.h = h;

      checks.h = h;

      # Do *NOT* expose it *ALSO* via DevShell, because that's too confusing: devshells.default = { devshell.packages = [ h ]; };
    };
}
