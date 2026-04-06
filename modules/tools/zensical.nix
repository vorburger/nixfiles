_: {
  perSystem =
    { pkgs, ... }:
    {
      packages.zensical-site = pkgs.stdenvNoCC.mkDerivation {
        name = "zensical-site";
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

      devshells.default = {
        commands = [
          {
            name = "zensical-serve";
            help = "Run zensical in dev mode (live update)";
            command = "${pkgs.zensical}/bin/zensical serve -f docs/mkdocs.yaml";
          }
        ];
      };
    };
}
