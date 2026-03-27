{ self, ... }:
{
  perSystem =
    {
      self',
      pkgs,
      ...
    }:
    {
      packages.lychee-offline = pkgs.writeShellScriptBin "lychee-offline" ''
        exec ${pkgs.lychee}/bin/lychee --offline "$@"
      '';

      checks = {
        markdownlint =
          pkgs.runCommand "markdownlint"
            {
              buildInputs = [ pkgs.markdownlint-cli2 ];
            }
            ''
              cd ${self}
              markdownlint-cli2 .
              touch $out
            '';

        shellcheck =
          pkgs.runCommand "shellcheck"
            {
              buildInputs = [ pkgs.shellcheck ];
            }
            ''
              cd ${self}
              find . -name "*.sh" -not -path "./.direnv/*" -not -path "*/.direnv/*" -exec shellcheck {} +
              touch $out
            '';

        lychee =
          pkgs.runCommand "lychee"
            {
              buildInputs = [
                self'.packages.lychee-offline
                pkgs.cacert
              ];
            }
            ''
              cd ${self}
              lychee-offline .
              touch $out
            '';
      };
    };
}
