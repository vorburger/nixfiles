{
  flake.nixosModules.ui =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.symlinkJoin {
          name = "kitty";
          paths = [ pkgs.kitty ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/kitty \
              --add-flags "--start-as=fullscreen"
          '';
        })
        pkgs.brave
      ];
    };
}
