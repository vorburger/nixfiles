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
  name = "gnome-vm";
  diskoDevice = "/dev/vda";
  modules = [
    (
      { config, ... }:
      {
        system.stateVersion = config.system.nixos.release;
      }
    )
    self.nixosModules.target-vm-1G-grub-8G
    self.nixosModules.personality-gnome
  ];
  # NOTE: Do NOT add a testScript / enableVMTest here!
  # Building a full graphical desktop VM test in flake checks pulls in
  # 11,000+ derivation requisites (GNOME, Chromium/Brave, Electron/VS Code, kernel,
  # firmware), taking 15+ minutes on cold runs and slowing down fast checks.
  # gnome-vm is already syntax- and option-evaluated by nixos-eval-gnome-vm in checks.
  # To test gnome-vm interactively in a VM, run: vm gnome-vm clean
}
