{ self, ... }:
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
    ../services/_ch.nix
    ../services/_networking.nix
    ../services/_openssh.nix
    ../services/_nix.nix
  ];
}
