{
  flake.nixosModules.personality-workstation =
    { pkgs, inputs, ... }:
    {
      system.stateVersion = "26.05";

      environment.systemPackages = [
        # TODO Move to dotfiles repo?
        pkgs.pass
        pkgs.starship
        pkgs.shellcheck
        inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli # agy (UI is in ui.nix)
      ];

      services.gpg-with-yubikey.enable = true;
      services.ssh-tpm-agent.enable = true;
      services.ssh-agent-mux.enable = true;
      services.pipewire-extra.enable = true;
      services.fprintd-extra.enable = true;
      services.kmscon-extra.enable = true;
    };
}
