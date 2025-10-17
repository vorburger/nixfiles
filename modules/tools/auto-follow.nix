{
  # Alternative: https://github.com/spikespaz/allfollow
  flake-file.inputs.auto-follow.url = "github:fzakaria/nix-auto-follow";

  perSystem =
    { inputs', ... }:
    {
      devshells.default = {
        devshell.packages = [ inputs'.auto-follow.packages.default ];
      };
    };
}
