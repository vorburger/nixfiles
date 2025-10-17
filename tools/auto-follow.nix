{
  perSystem =
    { inputs', ... }:
    {
      devshells.default = {
        devshell.packages = [ inputs'.auto-follow.packages.default ];
      };
    };
}
