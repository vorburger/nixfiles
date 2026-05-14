_: {
  perSystem =
    { pkgs, self', ... }:
    {
      packages.documentation = pkgs.stdenvNoCC.mkDerivation {
        name = "documentation";
        src = ../../docs;
        nativeBuildInputs = [ pkgs.zensical ];
        buildPhase = ''
          zensical build -f mkdocs.yaml
        '';
        installPhase = ''
          mkdir -p $out
          cp -r site/* $out/
        '';
      };

      checks.documentation = self'.packages.documentation;

      apps.watch-documentation = {
        type = "app";
        program = pkgs.writeShellScriptBin "watch-documentation" ''
          ${pkgs.zensical}/bin/zensical serve -f docs/mkdocs.yaml
        '';
        meta.description = "Watch documentation with live-rebuilds";
      };

      devshells.default = {
        commands = [
          {
            name = "watch-documentation";
            help = "Run zensical in dev mode (live update)";
            command = "${pkgs.zensical}/bin/zensical serve -f docs/mkdocs.yaml";
          }
        ];
      };
    };
}
