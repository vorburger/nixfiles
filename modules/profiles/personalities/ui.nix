{
  flake.nixosModules.ui =
    { pkgs, self, ... }:
    let
      inherit (import ../../../lib/wrap-flags.nix { inherit pkgs; }) wrapFlags;
    in
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true; # Needed for certain old Minecraft launchers/compatibility
      };

      environment.systemPackages = [
        (wrapFlags pkgs.kitty "kitty" "--start-as=fullscreen")
        pkgs.brave
        pkgs.prismlauncher # Minecraft! https://wiki.nixos.org/wiki/Prism_Launcher
        self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity
      ];
    };
}
