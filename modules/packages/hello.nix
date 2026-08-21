let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
in
mkSecret {
  name = "hello";
  moduleName = "hello";
  mode = "0444";
}
// {
  perSystem =
    { pkgs, ... }:
    let
      hello = pkgs.writeShellApplication {
        name = "hello";
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
      packages.hello = hello;

      checks.hello = hello;

      # Do *NOT* expose it *ALSO* via DevShell, because that's too confusing: devshells.default = { devshell.packages = [ hello ]; };
    };
}
