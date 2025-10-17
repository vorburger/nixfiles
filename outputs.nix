inputs:
inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  imports = [
    ./modules/tools/auto-follow.nix
    ./modules/tools/devshell.nix
    ./modules/tools/flake-file.nix
    ./modules/tools/fmt.nix
    ./modules/tools/git-hooks.nix
    ./modules/tools/systems.nix
  ];
}
