{
  flake.nixosModules.personality-workstation =
    { pkgs, ... }:
    {
      system.stateVersion = "26.05";

      environment.systemPackages = [
        pkgs.starship # TODO Move to dotfiles repo
      ];

      services.initial-secrets.enable = true;
      services.gpg-with-yubikey.enable = true;
      services.ssh-tpm-agent.enable = true;
      services.ssh-agent-mux.enable = true;
      services.pipewire-extra.enable = true;
      services.fprintd-extra.enable = true;
      services.kmscon-extra.enable = true;
    };
}
