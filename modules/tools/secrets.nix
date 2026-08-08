{ inputs, ... }:
let
  secretPackages = pkgs: system: [
    pkgs.rage
    pkgs.age-plugin-tpm
    pkgs.age-plugin-yubikey
    inputs.ragenix.packages.${system}.default
    # TODO: Replace pass with something like passage (or a better alternative) eventually
    pkgs.pass
  ];
in
{
  flake-file.inputs.ragenix = {
    url = "github:yaxitech/ragenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  perSystem =
    { pkgs, system, ... }:
    {
      devshells.default = {
        devshell.packages = secretPackages pkgs system;
      };
    };

  flake.nixosModules.secrets =
    { pkgs, ... }:
    {
      imports = [ inputs.ragenix.nixosModules.default ];

      environment.systemPackages = secretPackages pkgs pkgs.stdenv.hostPlatform.system;

      # Ensure pinentry and age/rage passphrase UI can bind to the current terminal TTY
      environment.interactiveShellInit = ''
        export GPG_TTY=$(tty)
      '';
      programs.fish.interactiveShellInit = ''
        set -gx GPG_TTY (tty)
      '';
    };
}
