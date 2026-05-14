{
  flake.nixosModules.openssh-extra =
    { config, lib, ... }:
    let
      cfg = config.services.openssh-extra;
    in
    {
      options.services.openssh-extra = {
        enable = lib.mkEnableOption "extra OpenSSH configuration";
      };

      config = lib.mkIf cfg.enable {
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "no";
        services.openssh.settings.PasswordAuthentication = false;
        services.openssh.settings.AllowTcpForwarding = false;
        services.openssh.settings.X11Forwarding = false;

        networking.firewall.allowedTCPPorts = [ 22 ];
      };
    };
}
