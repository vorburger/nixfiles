{ pkgs, ... }:

{
  security.tpm2.enable = true;

  # Install the ssh-tpm-agent package
  environment.systemPackages = [
    pkgs.ssh-tpm-agent
    # See https://github.com/NixOS/nixpkgs/issues/505869
    pkgs.keyutils
  ];

  systemd.services.ssh-tpm-agent = {
    description = "ssh-tpm-agent";
    after = [ "pinned.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ssh-tpm-agent}/bin/ssh-tpm-agent";
      KeyringMode = "inherit";
      Restart = "always";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.services."system-ask-password-wall" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };
}
