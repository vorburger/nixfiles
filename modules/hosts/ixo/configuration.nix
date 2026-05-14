{ inputs, self, ... }:
{
  flake.nixosModules.ixo = {
    imports = [
      ../_common.nix
      ./_hardware-configuration.nix
      inputs.disko.nixosModules.disko
      (import ../../disko/_boot-and-ext4.nix { device = "/dev/nvme0n1"; })
      ../../users/_vorburger.nix
      (
        { pkgs, ... }:
        {
          networking.hostName = "ixo";
          system.stateVersion = "26.05";

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

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
        }
      )
    ];
  };

  flake.nixosConfigurations.ixo = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [ self.nixosModules.ixo ];
  };

  imports = [
    (import ../../tools/_mk-test.nix { inherit inputs self; } "ixo-boot" self.nixosModules.ixo null)
  ];
}
