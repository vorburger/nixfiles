let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.sudo-ssh-agent-auth = mkService {
    name = "sudo-ssh-agent-auth";
    description = "Sudo SSH Agent Authentication";
    content = {
      # Enable pam_ssh_agent_auth for passwordless sudo using SSH agent keys
      security.pam.sshAgentAuth.enable = true;
      security.pam.services.sudo.sshAgentAuth = true;
    };
  };
}
