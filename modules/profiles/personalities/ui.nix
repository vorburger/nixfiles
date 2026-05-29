{
  flake.nixosModules.ui =
    { pkgs, self, ... }:
    let
      inherit (import ../../../lib/wrap-flags.nix { inherit pkgs; }) wrapFlags;
    in
    {
      environment.systemPackages = [
        (wrapFlags pkgs.kitty "kitty" "--start-as=fullscreen")
        pkgs.brave
        self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity
      ];
    };
}
