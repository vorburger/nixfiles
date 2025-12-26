{
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.AllowTcpForwarding = false;
  services.openssh.settings.X11Forwarding = false;

  networking.firewall.allowedTCPPorts = [ 22 ];
}
