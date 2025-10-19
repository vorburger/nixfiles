# Run GNU `hello` from `nixpkgs`

## Prerequisites

- Have [the `nix` CLI Nix installed](../reference/nix-cli.md)
- You do NOT require a NixOS system for this; any Linux distribution or macOS will do.

## Hello, world!

```sh
$ nix run nixpkgs#hello
Hello, world!
```

This ran [GNU `hello`](https://www.gnu.org/software/hello) from the `nixpkgs` Nix package collection, where
it's but one of [over 120 000 software packages available](https://search.nixos.org/packages?channel=25.05&show=hello&query=hello)!

Nix is all about reproducible, declarative, and isolated software environments.

You can [view the package definition for GNU `hello`](https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/he/hello/package.nix#L47).
