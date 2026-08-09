{
  flake.nixosModules.h = {
    age.secrets.hello-secret = {
      file = ../../secrets/encrypted/hello-secret.age;
      mode = "0444";
    };
  };

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
          else
            echo "MISSING /run/secrets/hello-secret"
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
