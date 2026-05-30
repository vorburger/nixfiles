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
        # Work around https://github.com/nix-community/nixos-anywhere/issues/613
        users.users.root.openssh.authorizedKeys.keys = import ../users/_vorburger-authorizedKeys.nix;

        nixpkgs.overlays = lib.mkVMOverride [ ];

        console = {
          earlySetup = true;
          packages = with pkgs; [ terminus_font ];
          font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
        };

        boot.kernelParams = [ "video=1920x1080" ];
      }
    )
  ];
  testScript = ''
    machine.wait_for_unit("sshd.service")
    machine.succeed("ssh-keygen -t ed25519 -N \"\" -f /tmp/test-key")
    machine.succeed("mkdir -p /root/.ssh && cat /tmp/test-key.pub >> /root/.ssh/authorized_keys")
    # SSH into root@localhost should succeed if PermitRootLogin is yes/prohibit-password
    machine.succeed("ssh -i /tmp/test-key -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@localhost 'echo hello'")
  '';
}
