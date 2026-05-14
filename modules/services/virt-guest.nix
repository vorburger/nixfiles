{
  flake.nixosModules.virt-guest =
    { config, lib, ... }:
    let
      cfg = config.services.virt-guest;
    in
    {
      options.services.virt-guest = {
        enable = lib.mkEnableOption "optimized VM guest settings";
        memorySize = lib.mkOption {
          type = lib.types.int;
          default = 8192;
          description = "RAM size for the VM in MB.";
        };
        cores = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Number of CPU cores for the VM.";
        };
      };

      config = lib.mkIf cfg.enable {
        boot.kernelModules = [ "virtio_gpu" ];
        hardware.graphics.enable = true;
        services.xserver.videoDrivers = [ "virtio" ];

        security.sudo.extraRules = [
          {
            users = [ "vorburger" ];
            commands = [
              {
                command = "ALL";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
        services.getty.autologinUser = "vorburger";
        services.displayManager.autoLogin = {
          enable = true;
          user = "vorburger";
        };

        virtualisation = {
          vmVariant = {
            virtualisation = {
              inherit (cfg) memorySize cores;
              forwardPorts = [
                {
                  from = "host";
                  host.port = 2222;
                  guest.port = 22;
                }
              ];
              qemu.options = [
                "-vga none"
                "-device virtio-vga-gl"
                "-display gtk,gl=on"
              ];
            };
          };
        };
      };
    };
}
