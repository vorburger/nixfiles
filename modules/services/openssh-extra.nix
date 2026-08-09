let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.openssh-extra = mkService {
    name = "openssh-extra";
    description = "extra OpenSSH configuration";
    content = {
      services.openssh.enable = true;
      services.openssh.settings.PermitRootLogin = "no";
      services.openssh.settings.PasswordAuthentication = false;
      services.openssh.settings.KbdInteractiveAuthentication = false;
      services.openssh.settings.AllowTcpForwarding = false;
      services.openssh.settings.X11Forwarding = false;

      services.openssh.extraConfig = ''
        Match User vorburger
          PasswordAuthentication no
          KbdInteractiveAuthentication no
          PubkeyAuthentication yes
      '';

      services.openssh.hostKeys = [
        # Do not generate an RSA SSH host key, only an Ed25519 key.
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      networking.firewall.allowedTCPPorts = [ 22 ];
    };
  };
}
