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
      pkgs,
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
        #
        # Note: Must be placed at priority 70 via services.udev.packages rather than
        # services.udev.extraRules (which writes 99-local.rules), because systemd-logind's
        # seat assignment (71-seat.rules) and ACL assignment (73-seat-late.rules) execute at 71 and 73.
        services.udev.packages = lib.mkIf cfg.captureMouseClicks [
          (pkgs.writeTextFile {
            name = "openscreen-mouse-uaccess";
            destination = "/etc/udev/rules.d/70-openscreen-mouse.rules";
            text = ''
              KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", ENV{ID_INPUT_KEYBOARD}!="1", TAG+="uaccess"
              KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{ID_INPUT_KEYBOARD}!="1", TAG+="uaccess"
            '';
          })
        ];
      };
    };
}
