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
        pkgs.handbrake
        pkgs.vlc
        pkgs.vscode
        self.packages.${pkgs.stdenv.hostPlatform.system}.antigravity
      ];

      services.pipewire.extraConfig.pipewire."99-echo-cancel" = {
        "context.modules" = [
          {
            name = "libpipewire-module-echo-cancel";
            args = {
              "source.props" = {
                "node.name" = "echo-cancel-source";
                "node.description" = "Filtered Microphone";
              };
              "aec.args" = {
                "webrtc.noise_suppression" = true;
                "webrtc.extended_filter" = true;
              };
            };
          }
        ];
      };
    };
}
