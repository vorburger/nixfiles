{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (import ../../lib/mk-host.nix { inherit inputs self lib; }) mkHost;
in
mkHost {
  name = "installer";
  useCommon = false; # Do not use common desktop configs (openssh-extra disables root logins, which breaks nixos-anywhere)
  useDefaultUser = false;
  modules = [
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
        users.users.root.openssh.authorizedKeys.keys = import ../users/_vorburger-authorizedKeys.nix;

        console = {
          earlySetup = true;
          packages = with pkgs; [ terminus_font ];
          font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
        };

        boot.kernelParams = [ "video=1920x1080" ];
      }
    )
  ];
}
