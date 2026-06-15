let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.ssh-agent-mux = mkService {
    name = "ssh-agent-mux";
    description = "SSH agent multiplexer";
    content =
      { pkgs, ... }:
      {
        # Install the ssh-agent-mux package
        environment.systemPackages = [ pkgs.ssh-agent-mux ];

        # Configure the ssh-agent-mux systemd user service
        systemd.user.services.ssh-agent-mux = {
          unitConfig = {
            Description = "SSH agent multiplexer";
            # Ensure it starts after the agents it multiplexes
            After = [
              "gpg-agent-ssh.socket"
              "ssh-tpm-agent.service"
            ];
            # We don't want to "require" them because it should work even if some are missing (later)
          };
          wantedBy = [ "default.target" ];
          serviceConfig = {
            # %t is /run/user/%U
            # Add more agent sockets here as needed (e.g. TPM agent)
            ExecStart = "${pkgs.ssh-agent-mux}/bin/ssh-agent-mux -l %t/ssh-agent-mux.sock %t/gnupg/S.gpg-agent.ssh %t/ssh-tpm-agent.sock";
            Restart = "always";
          };
        };

        # Set SSH_AUTH_SOCK to the multiplexer socket locally
        environment.interactiveShellInit = ''
          if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
            # Preserve forwarded agent in remote SSH sessions
            :
          else
            if [ -n "$XDG_RUNTIME_DIR" ]; then
              export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent-mux.sock
            else
              export SSH_AUTH_SOCK=/run/user/$(id -u)/ssh-agent-mux.sock
            fi
          fi
        '';

        programs.fish.interactiveShellInit = ''
          if set -q SSH_CLIENT; or set -q SSH_TTY
            # Preserve forwarded agent in remote SSH sessions
          else
            if set -q XDG_RUNTIME_DIR
              set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent-mux.sock
            else
              set -gx SSH_AUTH_SOCK /run/user/(id -u)/ssh-agent-mux.sock
            end
          end
        '';
      };
  };
}
