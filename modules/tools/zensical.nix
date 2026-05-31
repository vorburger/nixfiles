_: {
  perSystem =
    { pkgs, self', ... }:
    let
      watchCommand = "cd docs && ${pkgs.zensical}/bin/zensical serve -f mkdocs.yaml";
      watchDescription = "Watch documentation with live-rebuilds";
    in
    {
      packages.documentation = pkgs.stdenvNoCC.mkDerivation {
        name = "documentation";
        src = ../../docs;
        nativeBuildInputs = [ pkgs.zensical ];
        buildPhase = ''
          zensical build -f mkdocs.yaml --strict
        '';
        installPhase = ''
          mkdir -p $out
          cp -r site/* $out/
        '';
      };

      checks.documentation = self'.packages.documentation;

      apps.watch-documentation = {
        type = "app";
        program = pkgs.writeShellScriptBin "watch-documentation" watchCommand;
        meta.description = watchDescription;
      };

      devshells.default = {
        commands = [
          {
            name = "watch-documentation";
            help = watchDescription;
            command = watchCommand;
          }
        ];
      };
    };
}
