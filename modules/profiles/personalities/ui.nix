{
  flake.nixosModules.ui =
    { pkgs, inputs, ... }:
    let
      inherit (import ../../../lib/wrap-flags.nix { inherit pkgs; }) wrapFlags;
    in
    {
      environment.systemPackages = [
        (wrapFlags pkgs.kitty "kitty" "--start-as=fullscreen")
        pkgs.brave
        (wrapFlags inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default "antigravity"
          "--start-maximized"
        ) # CLI is in workstation.nix
      ];
    };
}
