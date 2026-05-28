# TODO Move ui.nix to //modules/profiles/personalities
{
  flake.nixosModules.ui =
    { pkgs, inputs, ... }:
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
        inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
