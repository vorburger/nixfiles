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
          let
            mdSource = pkgs.lib.cleanSourceWith {
              src = self;
              filter =
                path: type:
                type == "directory"
                || pkgs.lib.hasSuffix ".md" path
                || pkgs.lib.hasSuffix ".markdownlint.json" path
                || pkgs.lib.hasSuffix ".markdownlint.yaml" path;
            };
          in
          pkgs.runCommand "markdownlint"
            {
              buildInputs = [ pkgs.markdownlint-cli2 ];
            }
            ''
              cd ${mdSource}
              markdownlint-cli2 .
              touch $out
            '';

        shellcheck =
          let
            shSource = pkgs.lib.cleanSourceWith {
              src = self;
              filter = path: type: type == "directory" || pkgs.lib.hasSuffix ".sh" path;
            };
          in
          pkgs.runCommand "shellcheck"
            {
              buildInputs = [ pkgs.shellcheck ];
            }
            ''
              cd ${shSource}
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
