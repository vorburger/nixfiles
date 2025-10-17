{
  description = "Nix files of https://www.vorburger.ch";

  inputs = {
    # ALWAYS run "auto-follow -i" AFTER adding inputs and running `nix flake check`
    # TODO Automate this...
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    git-hooks.url = "github:cachix/git-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    auto-follow.url = "github:fzakaria/nix-auto-follow";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
