{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (import ../../../lib/mk-host.nix { inherit inputs self lib; }) mkHost;
in
mkHost {
  name = "ixo";
  diskoDevice = "/dev/nvme0n1";
  modules = [
    ./_hardware-configuration.nix
    (
      { pkgs, ... }:
      {
        system.stateVersion = "26.05";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        environment.systemPackages = [
          pkgs.starship # TODO Move to dotfiles repo
        ];

        services.initial-secrets.enable = true;
        services.gpg-with-yubikey.enable = true;
        services.ssh-tpm-agent.enable = true;
        services.ssh-agent-mux.enable = true;
        services.pipewire-extra.enable = true;
        services.fprintd-extra.enable = true;
        services.kmscon-extra.enable = true;
      }
    )
  ];
}
