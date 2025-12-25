# `nixos-generate-config`

See also https://github.com/NixOS/nixos-hardware.

## Misc

To run it e.g. from Fedora, use:

    sudo (which nixos-generate-config) --dir modules/hosts/anarres --flake

    sudo chown vorburger:vorburger modules/hosts/anarres/*

## Troubleshooting

### Failed to retrieve subvolume info for /

This just means that you are not running it as `root`.
