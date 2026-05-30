let
  inherit (import ../../lib/mk-service.nix) mkService;
in
{
  flake.nixosModules.ssh-tpm-agent = mkService {
    name = "ssh-tpm-agent";
    description = "SSH TPM agent support";
    content =
      { pkgs, config, ... }:
      {
        security.tpm2.enable = true;

        # Install the ssh-tpm-agent package
        environment.systemPackages = [
          pkgs.ssh-tpm-agent
          # See https://github.com/NixOS/nixpkgs/issues/505869
          pkgs.keyutils
        ];

        systemd.user.sockets.ssh-tpm-agent = {
          description = "ssh-tpm-agent socket";
          socketConfig = {
            ListenStream = "%t/ssh-tpm-agent.sock";
            DirectoryMode = "0700";
          };
          wantedBy = [ "sockets.target" ];
        };

        systemd.user.services.ssh-tpm-agent = {
          description = "ssh-tpm-agent";
          serviceConfig = {
            ExecStart = "${pkgs.ssh-tpm-agent}/bin/ssh-tpm-agent --no-load";
            ExecStartPost = "-${pkgs.ssh-tpm-agent}/bin/ssh-tpm-add -c";
            Environment = [
              "SSH_ASKPASS=${config.programs.ssh.askPassword}"
              "SSH_ASKPASS_REQUIRE=prefer"
            ];
            KeyringMode = "inherit";
            Restart = "always";
          };
        };

        systemd.services."system-ask-password-wall" = {
          enable = true;
          wantedBy = [ "multi-user.target" ];
        };
      };
  };
}
