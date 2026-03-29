{
  device,
  ...
}:
{
  disko.devices = {
    disk = {
      my-disk = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # Partition used for GRUB stage 1.5, for Legacy BIOS boot on GPT
            # (Alternative is to use a MBR partitioned disk, but then we cannot have
            #  more than 4 primary partitions etc. A pure UEFI boot would not need this.)
            boot = {
              size = "1M";
              type = "EF02"; # This is the "BIOS boot partition" code
            };
            # ESP for UEFI boot. Not required for Legacy BIOS boot, but no harm either;
            # and having it makes it easier to later switch to UEFI boot if desired, or test dual-compatibility.
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
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
