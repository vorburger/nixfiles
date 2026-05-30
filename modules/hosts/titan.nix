{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-host.nix { inherit inputs self lib; }) mkHost;
in
mkHost {
  name = "titan";
  modules = [
    # TODO self.nixosModules.target-thinkstation
    self.nixosModules.personality-workstation
    self.nixosModules.personality-gnome
    (_: {
      services.zfs-extra.enable = true;
      networking.hostId = "8425e349";

      # Dummy file systems and boot loader because HW target is TBD
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "nodev";
    })
  ];
}
