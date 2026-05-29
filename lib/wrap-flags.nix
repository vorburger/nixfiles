# Helper function to wrap a package's binary with extra command-line flags.
{ pkgs }:
{
  wrapFlags =
    pkg: binaryName: flags:
    pkgs.symlinkJoin {
      name = pkg.name or "wrapped-package";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${binaryName} \
          --add-flags "${flags}"
      '';
    };
}
