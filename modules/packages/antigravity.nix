# This module defines a patched version of Google Antigravity.
# Antigravity is a standalone Electron app with hardcoded window dimensions (1400x900)
# defined in its BrowserWindow configuration. Because Electron/Chromium ignores command-line
# flags like `--start-maximized` when the dimensions are set explicitly, this module patches
# the application code directly (in `dist/utils.js` inside `resources/app.asar`) to make it
# always start maximized on startup.
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;

      # Get the original src by reading the flake's versions.json
      versions = builtins.fromJSON (builtins.readFile "${inputs.antigravity}/artifacts/versions.json");
      platformInfo = versions."Antigravity 2.0".${system};
      originalSrc = pkgs.fetchurl {
        inherit (platformInfo) url;
        sha256 = platformInfo.hash;
      };

      patchedSrc = pkgs.stdenv.mkDerivation {
        name = "antigravity-patched-src";
        src = originalSrc;
        nativeBuildInputs = [
          pkgs.asar
          pkgs.gnutar
          pkgs.gzip
        ];
        dontConfigure = true;
        dontBuild = true;

        unpackPhase = ''
          tar -xzf $src
          for d in *; do
            if [ -d "$d" ]; then
              cd "$d"
              break
            fi
          done
        '';

        patchPhase = ''
          if [ -f "resources/app.asar" ]; then
            asar extract resources/app.asar temp_app
            substituteInPlace temp_app/dist/utils.js \
              --replace-fail "const win = new electron_1.BrowserWindow({" "const win = new electron_1.BrowserWindow({ show: false, " \
              --replace-fail "void win.loadURL(url);" "win.maximize(); win.show(); void win.loadURL(url);"
            asar pack temp_app resources/app.asar
            rm -rf temp_app
          fi
        '';

        installPhase = ''
          dir_name=$(basename "$PWD")
          cd ..
          tar -czf $out "$dir_name"
        '';
      };
    in
    {
      packages.antigravity = inputs.antigravity.packages.${system}.default.override {
        srcOverride = patchedSrc;
      };
    };
}
