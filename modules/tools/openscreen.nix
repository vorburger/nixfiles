{ inputs, ... }:
{
  flake-file.inputs.openscreen = {
    url = "github:getopenscreen/openscreen";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
    in
    {
      packages.openscreen = inputs.openscreen.packages.${system}.openscreen;
    };

  flake.nixosModules.openscreen =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.programs.openscreen;
    in
    {
      imports = [
        inputs.openscreen.nixosModules.default
      ];

      options.programs.openscreen = {
        captureMouseClicks = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to grant the active desktop user access to mouse evdev nodes via udev uaccess,
            enabling OpenScreen to record mouse click animations without adding the user to the `input` group
            (which would expose keyboards to unprivileged user processes).
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        # Grant desktop user access to mouse evdev devices so OpenScreen can capture click telemetry
        # without exposing keyboards or adding the user to the `input` group.
        services.udev.extraRules = lib.mkIf cfg.captureMouseClicks ''
          KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", ENV{ID_INPUT_KEYBOARD}!="1", TAG+="uaccess"
        '';
      };
    };
}
