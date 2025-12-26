{ inputs, ... }:
{
  flake.nixosConfigurations.test1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.disko.nixosModules.disko
      ../disko/_boot-and-ext4.nix
      ../users/_tester.nix
      # TODO users/vorburger.nix
      (
        { pkgs, ... }:
        {
          boot.loader.grub.enable = true;
          boot.loader.grub.devices = [ "/dev/sda" ]; # TODO use disko to get device

          # TODO Verify if hostname is automatically set from flake name / attribute name or not?
          networking.hostName = "test1";

          services.openssh.enable = true;
          services.openssh.settings.PermitRootLogin = "prohibit-password";
          # virtualisation.forwardPorts = [
          #   {
          #     from = "host";
          #     host.port = 2222;
          #     guest.port = 22;
          #     # You can optionally specify the protocol (default is "tcp")
          #     # protocol = "tcp";
          #   }
          # ];

          users.users.vorburger = {
            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+qSqOeDos2pCI1Q0tm44FgghgvOaX5WuPAXKRIw1/bwahPXnvTwJbSNdnIbQyDWZCmvJaXr6wnDP8faQBZcIyBBjD4JOoVONfvTw2/RKPHBB9eb6h8q6Jl1STsCk/8+Qv5PXhSjCJQ2mJdaE56wKrrPL/bIyOInx1KQj0rygV96KFj67CeXpjpMqOxAxcJyjp6/cxAGJyL81lcjA2HFKhwjeHS71ipOstmG+n6cOjd2x5V5Qv7j1x2zKSnxCJOU7PHphm7UqPUlvCcrKLq+YZ2VWSjjHiu+GUIR7dp1HG73W5uSmhgAM2fQEhldT53Lc2tCYwyrMq/C1hAtq/S26BxmibR8jmAxIqJ4JB9Njv/r97/6amI8LxnzuRBnDhA6cW9JHUBrNoG41vTwopdAz9DjaklzeRAjStoQY9rE6Ck6GXzuqUuLaBryS1JETKpxWvbQrnFA/yS9qFl/oDlfjYT0dX4oeWK58tCgdDD42SF4fUP6zpQZzHx4iwKGukMV3e87DW5tKTs2yCQzeBgw664mlG0WbYdj1TZ0n7MRXAr9aKpPSiW0H94A+0cZS/VJdVAxrRgbPv3Uk9W7E/tq4aMySRTm6ZlU0HTKlkg5adnQl5yM8ZxyOdYybnsq9ZyyUlsc9cmEfyOvIOP9cvi2pN5cpmDNG+pZ+mEHJ5aU95WQ=="
              "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBG9S0hTqG+qEDmyIsOruZbwNqcmw43mDV0IsSFpXOCyGdHyo5ohaKwD3tL68jOrR9CxC5fJ1cjUI9Yv8AsbE2doNOAU0YGyNjsiBuY1NHJl4f/fW+Vm7np+HPBGyBJrcJQ== vorburger@anarres"
            ];
            isNormalUser = true;
            extraGroups = [
              "wheel"
              # ? "networkmanager"
            ];
            packages = with pkgs; [
              # TODO Replace with https://github.com/vorburger/vorburger-dotfiles-bin-etc/tree/main/dotfiles/home-manager ...
              git
              nano
            ];
          };

          system.stateVersion = "25.05";
        }
      )
    ];
  };
}
