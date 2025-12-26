{ inputs, lib, ... }:
{
  flake.nixosConfigurations.installer = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ../services/_openssh.nix
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      (
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.git
            pkgs.nano
            pkgs.disko
          ];

          users.users.nixos.openssh.authorizedKeys.keys = import ../users/_vorburger-authorizedKeys.nix;

          console = {
            earlySetup = true;
            packages = with pkgs; [ terminus_font ];
            font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
          };

          boot.kernelParams = [ "video=1920x1080" ];

          # Use latest kernel (for better hardware support)
          # boot.kernelPackages = pkgs.linuxPackages_latest;
        }
      )
    ];
  };
}
