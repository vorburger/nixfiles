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

    # NOT as long as there is a --user level other one in services/_ssh-tpm-agent.nix
    #services.ssh-tpm-agent.enable = config.security.tpm2.enable;

    home.sessionVariables = {
      SSH_AUTH_SOCK = lib.mkOverride 10 "$XDG_RUNTIME_DIR/ssh-agent-mux.sock";
    };

    # Force, because dotfiles also sets this
    home.file."${config.users.users.vorburger.home}/.gnupg/gpg.conf".force = true;
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

  # TODO Enable autologin AFTER we have LUKS which will have another password, first..
  # services.getty.autologinUser = "vorburger";

  users.users.vorburger = {
    description = "Michael Vorburger";
    openssh.authorizedKeys.keys = import ./_vorburger-authorizedKeys.nix;
    isNormalUser = true;
    extraGroups = [
      "tss"
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Anything not on https://github.com/vorburger/dotfiles/tree/main/dotfiles/home-manager ...
      home-manager
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
