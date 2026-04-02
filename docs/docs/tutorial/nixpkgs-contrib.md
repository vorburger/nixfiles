# How to contribute to nixpkgs

1. Clone https://github.com/NixOS/nixpkgs.
   Yes, it's big. But not that big either, it's fine (3.5 GB).

1. Build package of interest; e.g. `nix-build -A ssh-tpm-agent`

1. It's now in `./result/bin/ssh-tpm-agent --help`

1. Modify package source with your contributions

1. Re-build, test, iterate.

1. Branch, Commit, Pull Request.
