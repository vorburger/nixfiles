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

  # User Private Groups (UPG) setup:
  # By default, NixOS sets isNormalUser's primary group to GID 100 (users).
  # However, a shared GID 100 means that any user on the system with group-read
  # permission (e.g. 0640/0750) could read any other user's files.
  # Using UPG (a group dedicated to the user) ensures files aren't leaked to
  # other users via group permissions, which is the standard on Fedora and Debian.
  # We also pin the UID and GID to 1000 for consistency and compatibility
  # with Fedora setups (e.g., when sharing external storage or NFS).
  users.groups.vorburger = {
    gid = 1000;
  };

  users.users.vorburger = {
    description = "Michael Vorburger";
    uid = 1000;
    group = "vorburger";
    openssh.authorizedKeys.keys = import ./_vorburger-authorizedKeys.nix;
    isNormalUser = true;
    initialPassword = "x";
    extraGroups = [
      "tss"
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # Anything not on https://github.com/vorburger/dotfiles/tree/main/dotfiles/home-manager ...
      home-manager
      openssh
    ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  system.activationScripts.expire-vorburger-password =
    lib.mkIf (!config.services.displayManager.autoLogin.enable)
      {
        text = ''
          if [ ! -e /var/lib/vorburger-password-expired ]; then
            if id -u vorburger >/dev/null 2>&1; then
              ${pkgs.shadow}/bin/chage -d 0 vorburger || true
              mkdir -p /var/lib
              touch /var/lib/vorburger-password-expired
            fi
          fi
        '';
        deps = [ "users" ];
      };

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
