{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager.users.vorburger = {
    imports = [
      "${inputs.vorburger-dotfiles}/home.nix"
      inputs.nix-index-database.homeModules.nix-index
    ];
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          source = pkgs.fetchurl {
            url = "https://www.vorburger.ch/gpg/vorburger.pgp.key.asc";
            sha256 = "1fckmv2akjayqy2iha004fzl8ggn1r2ra51i5wxdj09f9fzxv1j8";
          };
          trust = 5;
        }
      ];
    };
  };

  # NOT services.getty.autologinUser = "vorburger";

  users.users.vorburger = {
    description = "Michael Vorburger";
    openssh.authorizedKeys.keys = import ./_vorburger-authorizedKeys.nix;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
      # Anything not on https://github.com/vorburger/dotfiles/tree/main/dotfiles/home-manager ...
      home-manager
      # TODO Why is nano here instead of in dotfiles?
      nano
    ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # Required to avoid: "Existing file '/home/vorburger/.config/fish/config.fish' would be clobbered"
  home-manager.backupFileExtension = "home-manager_backup";

  systemd.services.home-manager-vorburger = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # See https://github.com/vorburger/dotfiles/blob/main/dotfiles/home-manager/flake.nix
  home-manager.extraSpecialArgs = {
    envHOME = config.users.users.vorburger.home;
    envUSER = config.users.users.vorburger.name;
    username = lib.mkDefault config.users.users.vorburger.name;
  };

  nix.settings.trusted-users = [ "vorburger" ];
}
