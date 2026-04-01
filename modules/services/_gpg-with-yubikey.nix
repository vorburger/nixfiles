{ pkgs, ... }:

{
  imports = [
    ./_ssh-agent-mux.nix
  ];

  # Enable the PC/SC Smart Card Daemon, required for GnuPG to communicate with YubiKeys
  services.pcscd.enable = true;

  # Enable Udev rules for YubiKeys
  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  # Enable the GnuPG agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Disable the default NixOS ssh-agent to ensure it doesn't conflict with GnuPG
  programs.ssh.startAgent = false;

  # Some setups need GPG_TTY for pinentry to work correctly
  environment.interactiveShellInit = ''
    export GPG_TTY=$(tty)
  '';
  programs.fish.interactiveShellInit = ''
    set -gx GPG_TTY (tty)
  '';

  # Ensure gnupg and useful tools are installed
  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-manager
    # pinentry-curses is usually handled by pinentryFlavor, but having it explicitly can help
    pinentry-curses
  ];
}
