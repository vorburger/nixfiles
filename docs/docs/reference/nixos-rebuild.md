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

## Alternatives

- Clan: https://docs.clan.lol/guides/nixos-rebuild/
- nixos-rebuild-ng #python: https://github.com/NixOS/nixpkgs/tree/master/pkgs/by-name/ni/nixos-rebuild-ng
- colmena #rust: https://github.com/colmena/colmena
- morph #go: https://github.com/DBCDK/morph
- nixops4: https://github.com/nixops4
- nixops: https://github.com/NixOS/nixops
- [NixOS `apply` script](https://github.com/nixops4/nixops4-nixos/issues/2) ?
