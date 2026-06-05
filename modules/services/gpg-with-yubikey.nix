let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.gpg-with-yubikey = mkService {
    name = "gpg-with-yubikey";
    description = "GPG with YubiKey support";
    extraOptions =
      { lib, ... }:
      {
        ssh = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable gpg-agent SSH socket support";
        };
      };
    content =
      {
        pkgs,
        lib,
        selfCfg,
        ...
      }:
      let
        inherit (selfCfg) ssh;
      in
      {
        # Explicitly allow GPG to lock down smartcard access profiles
        hardware.gpgSmartcards.enable = true;

        # Enable the PC/SC Smart Card Daemon, required for GnuPG to communicate with YubiKeys
        services.pcscd.enable = true;

        # Enable Udev rules for YubiKeys
        services.udev = {
          packages = with pkgs; [
            yubikey-personalization
            libfido2
          ];
        };

        # Enable the GnuPG agent
        programs.gnupg.agent = {
          enable = true;
          enableSSHSupport = ssh;
          enableExtraSocket = true;
          pinentryPackage = pkgs.pinentry-curses;
        };

        # If SSH, then disable the default NixOS ssh-agent to ensure it doesn't conflict with GnuPG
        programs.ssh.startAgent = !ssh;
        services.gnome.gcr-ssh-agent.enable = ssh;

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

        # If gpg-agent is already running before this socket activates,
        # systemd may refuse the socket and it remains missing.
        systemd.user.services.gpg-agent-ssh-recover = lib.mkIf ssh {
          unitConfig = {
            Description = "Recover missing GPG SSH socket";
            Wants = [
              "gpg-agent.socket"
              "gpg-agent-ssh.socket"
            ];
            After = [
              "gpg-agent.socket"
              "gpg-agent-ssh.socket"
            ];
          };
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "gpg-agent-ssh-recover" ''
              if [ ! -S "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh" ]; then
                ${pkgs.systemd}/bin/systemctl --user stop gpg-agent.service gpg-agent.socket gpg-agent-ssh.socket || true
                ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent || true
                ${pkgs.systemd}/bin/systemctl --user start gpg-agent.socket gpg-agent-ssh.socket
              fi
            '';
          };
        };
      };
  };
}
