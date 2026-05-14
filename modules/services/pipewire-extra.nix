let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.pipewire-extra = mkService {
    name = "pipewire-extra";
    description = "extra PipeWire configuration";
    content =
      { pkgs, ... }:
      {
        # Enable sound with pipewire.
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          # If you want to use JACK applications, uncomment this
          #jack.enable = true;
        };

        # This ensures the user services start even without a graphical login
        systemd.user.services.pipewire.wantedBy = [ "default.target" ];
        systemd.user.services.pipewire-pulse.wantedBy = [ "default.target" ];

        environment.systemPackages = [
          pkgs.sound-theme-freedesktop
          pkgs.pulseaudio # Provides `paplay` for audio alerts (and `pactl`)
        ];
      };
  };
}
