{
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = true;

  virtualisation.vmVariant = {
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 2222;
        guest.port = 22;
      }
    ];
  };
}
