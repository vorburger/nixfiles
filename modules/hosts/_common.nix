{ self, lib, ... }:
{
  imports = [
    self.nixosModules.zfs-extra
    self.nixosModules.virt-guest
    self.nixosModules.initial-secrets
    self.nixosModules.gpg-with-yubikey
    self.nixosModules.ssh-tpm-agent
    self.nixosModules.ssh-agent-mux
    self.nixosModules.pipewire-extra
    self.nixosModules.gnome-extra
    self.nixosModules.fprintd-extra
    self.nixosModules.kmscon-extra
    self.nixosModules.locale-ch
    self.nixosModules.networking-extra
    self.nixosModules.openssh-extra
    self.nixosModules.nix-extra
  ];

  services.locale-ch.enable = lib.mkDefault true;
  services.networking-extra.enable = lib.mkDefault true;
  services.openssh-extra.enable = lib.mkDefault true;
  services.nix-extra.enable = lib.mkDefault true;
}
