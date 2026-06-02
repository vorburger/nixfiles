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
  name = "titan-rescue";
  nixpkgs = inputs.nixpkgs-stable;
  diskoDevice = "/dev/disk/by-id/usb-Mass_Storage_Device_125C20100726-0:0";
  diskoModule = ../disko/_usb-rescue.nix;
  modules = [
    # Reuse all titan's OS configuration exactly as-is.
    # Only the disk layout and bootloader differ (via diskoModule above).
    self.nixosModules.personality-workstation
    self.nixosModules.personality-gnome
    (_: {
      # TODO Read from titan.nix
      system.stateVersion = "26.05";
      services.zfs-extra.enable = true;
      networking.hostId = "8425e349";

      hardware.amdgpu.initrd.enable = true; # sets boot.initrd.kernelModules = ["amdgpu"];

      # Override the hostName so the USB identifies itself distinctly
      networking.hostName = lib.mkForce "titan-rescue";
    })
  ];
}
