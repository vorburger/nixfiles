{ pkgs, ... }:

{
  # Enable the PC/SC Smart Card Daemon, required for GnuPG to communicate with YubiKeys
  services.pcscd.enable = true;

  # Enable Udev rules for YubiKeys
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # Enable the GnuPG agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Ensure gnupg is installed
  environment.systemPackages = with pkgs; [
    gnupg
  ];
}
