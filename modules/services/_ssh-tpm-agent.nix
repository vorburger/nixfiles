{ pkgs, ... }:

{
  security.tpm2.enable = true;

  # Install the ssh-tpm-agent package
  environment.systemPackages = [ pkgs.ssh-tpm-agent ];
}
