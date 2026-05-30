let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.virt-guest = mkService {
    name = "virt-guest";
    description = "optimized VM guest settings";
    extraOptions =
      { lib, ... }:
      {
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
    content =
      { cfg, ... }:
      {
        boot.kernelModules = [ "virtio_gpu" ];
        hardware.graphics.enable = true;
        services.xserver.videoDrivers = [ "virtio" ];

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
