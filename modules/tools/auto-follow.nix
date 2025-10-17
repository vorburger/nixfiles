# https://github.com/fzakaria/nix-auto-follow
# Alternative: https://github.com/spikespaz/allfollow
{
  perSystem =
    { inputs', ... }:
    {
      devshells.default = {
        devshell.packages = [ inputs'.auto-follow.packages.default ];
      };
    };
}
