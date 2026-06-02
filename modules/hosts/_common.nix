{
  self,
  lib,
  config,
  ...
}:
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
    self.nixosModules.zram
  ];

  services.locale-ch.enable = lib.mkDefault true;
  services.networking-extra.enable = lib.mkDefault true;
  services.openssh-extra.enable = lib.mkDefault true;
  services.sudo-ssh-agent-auth.enable = lib.mkDefault true;
  services.nix-extra.enable = lib.mkDefault true;
  services.fwupd-extra.enable = lib.mkDefault true;
  services.systemd-boot.enable = lib.mkDefault true;
  services.zram.enable = lib.mkDefault false;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  virtualisation.vmVariant = {
    services.virt-guest.enable = lib.mkDefault true;
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
    virtualisation.qemu.options = [
      "-vga none"
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };
}
