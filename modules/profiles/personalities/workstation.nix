{
  flake.nixosModules.personality-workstation =
    { pkgs, inputs, ... }:
    {
      environment.systemPackages = [
        pkgs.pass
        pkgs.pciutils
        pkgs.shellcheck
        pkgs.starship
        pkgs.unzip
        pkgs.usbutils

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
