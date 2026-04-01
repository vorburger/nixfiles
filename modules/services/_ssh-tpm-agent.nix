{ pkgs, ... }:

{
  # Install the ssh-tpm-agent package
  environment.systemPackages = [ pkgs.ssh-tpm-agent ];

  # Configure the ssh-tpm-agent systemd user service
  systemd.user.services.ssh-tpm-agent = {
    unitConfig = {
      Description = "SSH agent for TPM sealed keys";
    };
    wantedBy = [ "default.target" ];
    serviceConfig = {
      # %t is /run/user/%U
      ExecStart = "${pkgs.ssh-tpm-agent}/bin/ssh-tpm-agent -l %t/ssh-tpm-agent.sock";
      Restart = "always";
    };
  };
}
