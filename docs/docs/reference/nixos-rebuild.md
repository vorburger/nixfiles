# `nixos-rebuild` NixOS Rebuild

    man nixos-rebuild

- Manual: https://www.mankier.com/8/nixos-rebuild
- Wiki: https://wiki.nixos.org/wiki/Nixos-rebuild
- Source: https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nixos-rebuild/nixos-rebuild.sh

## VM

    nixos-rebuild build-vm --flake .#test1

## Local

    nixos-rebuild switch --flake .#myhostname

Or, historically: Edit `/etc/nixos/configuration.nix` and `sudo nixos-rebuild switch`.

## Remote

- https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html

See also [`nixos-anywhere`](nixos-anywhere.md).

## Images

    nixos-rebuild build-image --flake .#myhostname

## Troubleshooting

### It lacks a signature by a trusted key

    copying path '/nix/store/0ffsqaf744z1mdv0w0ind94ipk4mm71r-nix.conf' to 'ssh://ixo'...
    error: cannot add path '/nix/store/0ffsqaf744z1mdv0w0ind94ipk4mm71r-nix.conf' because it lacks a
    signature by a trusted key

This happens when your user is not in `nix.settings.trusted-users` at first.

### Read-only file system

    /etc/nix/nix.conf: Read-only file system

This initial problem can be worked around by using `--build-host $HOSTNEW --use-remote-sudo
     --ask-sudo-password`.

### sudo: a password is required

    sudo: a terminal is required to read the password; either use ssh's -t option or configure an askpass helper
    sudo: a password is required
    error: while running command with remote sudo, did you forget to use --ask-sudo-password?

This can be worked around by adding `--use-remote-sudo --ask-sudo-password` (and then entering the password when prompted).

## Alternatives

- Clan: https://docs.clan.lol/guides/nixos-rebuild/
- nixos-rebuild-ng #python: https://github.com/NixOS/nixpkgs/tree/master/pkgs/by-name/ni/nixos-rebuild-ng
- colmena #rust: https://github.com/colmena/colmena
- morph #go: https://github.com/DBCDK/morph
- nixops4: https://github.com/nixops4
- nixops: https://github.com/NixOS/nixops
- [NixOS `apply` script](https://github.com/nixops4/nixops4-nixos/issues/2) ?
