{
  flake.nixosModules.personality-workstation =
    {
      pkgs,
      inputs,
      self,
      ...
    }:
    {
      imports = [
        self.nixosModules.ragenix
      ];

      environment.systemPackages = [
        pkgs.dmidecode
        pkgs.efivar
        pkgs.efibootmgr
        pkgs.hdparm
        pkgs.lsof
        pkgs.nvme-cli # https://man.archlinux.org/man/nvme.1
        pkgs.pciutils # lspci
        pkgs.shellcheck
        pkgs.starship
        pkgs.unzip
        pkgs.usbutils # lsusb

        inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli # agy (UI is in ui.nix)
      ];

      services.gpg-with-yubikey.enable = true;
      services.ssh-tpm-agent.enable = true;
      services.ssh-agent-mux.enable = true;
      services.pipewire-extra.enable = true;
      services.fprintd-extra.enable = true;
      services.kmscon-extra.enable = true;
    };
}
