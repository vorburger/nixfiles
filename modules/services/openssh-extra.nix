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
      services.openssh.settings.AllowTcpForwarding = false;
      services.openssh.settings.X11Forwarding = false;

      networking.firewall.allowedTCPPorts = [ 22 ];
    };
  };
}
