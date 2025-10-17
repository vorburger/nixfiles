# TODO Expand this to at least pass some parameters to hello
{
  perSystem =
    { self', pkgs, ... }:
    {
      # nix run .#hello
      packages.hello = pkgs.hello;

      # nix develop -c hello
      devshells.default = {
        devshell.packages = [ self'.packages.hello ];
      };
    };
}
