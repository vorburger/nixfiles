{ self, lib, ... }:
{
  imports = [
    self.nixosModules.zfs-extra
    self.nixosModules.virt-guest
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
    self.nixosModules.sudo-ssh-agent-auth
    self.nixosModules.nix-extra
    self.nixosModules.fwupd-extra
    self.nixosModules.systemd-boot
  ];

  services.locale-ch.enable = lib.mkDefault true;
  services.networking-extra.enable = lib.mkDefault true;
  services.openssh-extra.enable = lib.mkDefault true;
  services.sudo-ssh-agent-auth.enable = lib.mkDefault true;
  services.nix-extra.enable = lib.mkDefault true;
  services.fwupd-extra.enable = lib.mkDefault true;
  services.systemd-boot.enable = lib.mkDefault true;
}
