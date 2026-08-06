let
  secretPackages = pkgs: [
    pkgs.rage
    pkgs.age-plugin-tpm
    pkgs.age-plugin-yubikey
    # TODO: Replace pass with something like passage (or a better alternative) eventually
    pkgs.pass
  ];
in
{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        devshell.packages = secretPackages pkgs;
      };
    };

  flake.nixosModules.secrets =
    { pkgs, ... }:
    {
      environment.systemPackages = secretPackages pkgs;

      # Ensure pinentry and age/rage passphrase UI can bind to the current terminal TTY
      environment.interactiveShellInit = ''
        export GPG_TTY=$(tty)
      '';
      programs.fish.interactiveShellInit = ''
        set -gx GPG_TTY (tty)
      '';
    };
}
