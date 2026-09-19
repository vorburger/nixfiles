let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.ssh-tpm-agent = mkService {
    name = "ssh-tpm-agent";
    description = "SSH TPM agent support";
    content =
      { pkgs, config, ... }:
      {
        security.tpm2.enable = true;

        # Install the ssh-tpm-agent package
        environment.systemPackages = [
          pkgs.ssh-tpm-agent
          # See https://github.com/NixOS/nixpkgs/issues/505869
          pkgs.keyutils
        ];

        systemd.user.sockets.ssh-tpm-agent = {
          description = "ssh-tpm-agent socket";
          socketConfig = {
            ListenStream = "%t/ssh-tpm-agent.sock";
            DirectoryMode = "0700";
          };
          wantedBy = [ "sockets.target" ];
        };

        systemd.user.services.ssh-tpm-agent = {
          description = "ssh-tpm-agent";
          serviceConfig = {
            ExecStart = "${pkgs.ssh-tpm-agent}/bin/ssh-tpm-agent --no-load";
            ExecStartPost = "-${pkgs.ssh-tpm-agent}/bin/ssh-tpm-add -c";
            Environment = [
              "SSH_ASKPASS=${config.programs.ssh.askPassword}"
              "SSH_ASKPASS_REQUIRE=prefer"
            ];
            KeyringMode = "inherit";
            Restart = "always";
          };
        };

        systemd.services."system-ask-password-wall" = {
          enable = true;
          wantedBy = [ "multi-user.target" ];
        };

        # Set SSH_AUTH_SOCK to the TPM agent socket locally, preserving forwarded agent in remote SSH sessions
        environment.interactiveShellInit = ''
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            :
          else
            if [ -n "$XDG_RUNTIME_DIR" ]; then
              export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-tpm-agent.sock
            else
              export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-tpm-agent.sock
            fi
          fi
        '';

        programs.fish.interactiveShellInit = ''
          if set -q SSH_CLIENT; or set -q SSH_TTY
            # Preserve forwarded agent in remote SSH sessions
          else
            if set -q XDG_RUNTIME_DIR
              set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-tpm-agent.sock
            else
              set -gx SSH_AUTH_SOCK /run/user/(id -u)/ssh-tpm-agent.sock
            end
          end
        '';
      };
  };
}
