{
  device,
  ...
}:
{
  # Rescue USB layout for titan-rescue:
  # - Pure UEFI boot with systemd-boot (safe for use on any machine: does NOT write EFI vars)
  # - Single ext4 root partition (simple, fast, no encryption needed for a rescue stick)
  # - No BIOS boot partition: USB targets modern UEFI machines only
  disko.devices = {
    disk = {
      rescue-usb = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # ESP: required for systemd-boot on UEFI
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Root: takes the rest of the USB stick
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                # noatime reduces USB write wear
                extraArgs = [
                  "-L"
                  "titan-rescue"
                ];
                mountOptions = [ "noatime" ];
              };
            };
          };
        };
      };
    };
  };

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;

  # IMPORTANT: Must be false on a USB stick.
  # Setting this to true would write boot entries into the EFI NVRAM of whichever
  # machine you plug the USB into, corrupting that machine's boot order.
  boot.loader.efi.canTouchEfiVariables = false;
}
