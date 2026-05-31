{
  device,
  ...
}:
{
  # Experimental host layout used by vinea:
  # - pure UEFI boot with systemd initrd + systemd-boot
  # - LVM for root/nix/home/var-lib datasets
  # - encrypted /home (LUKS + btrfs)
  # - three reserved ZFS-typed GPT partitions left intentionally empty
  disko.devices = {
    disk = {
      main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            zfs1 = {
              name = "zfs1";
              type = "BF01";
              size = "100G";
            };

            zfs2 = {
              name = "zfs2";
              type = "BF01";
              size = "100G";
            };

            zfs3 = {
              name = "zfs3";
              type = "BF01";
              size = "100G";
            };

            lvm = {
              name = "lvm";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "vg0";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vg0 = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "50G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };

          nix = {
            size = "100G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };

          home = {
            size = "200G";
            content = {
              type = "luks";
              name = "crypt-home";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };

          varlib = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/var/lib";
            };
          };
        };
      };
    };
  };

  boot.initrd.systemd.enable = true;
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
