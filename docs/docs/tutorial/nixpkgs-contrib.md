# How to contribute to nixpkgs

1. Clone https://github.com/NixOS/nixpkgs.
   Yes, it's big. But not that big either, it's fine (3.5 GB).

1. Build package of interest; e.g. `nix-build -A ssh-tpm-agent`

1. It's now in `./result/bin/ssh-tpm-agent --help`

1. Enter the package's _dev shell_ with `nix develop .#ssh-tpm-agent`
   (see also [`third_party`](https://github.com/vorburger/third_party))

1. Modify package source with your contributions, temporarily build it "directly" using `go` or whatever

1. Re-build full package as above, test output - iterate.

1. Branch, Commit, Pull Request.
