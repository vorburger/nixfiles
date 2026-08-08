{ inputs, ... }:
let
  secretPackages = pkgs: system: [
    pkgs.rage
    pkgs.ssh-to-age
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
    inputs = {
      nixpkgs.follows = "nixpkgs";
      agenix.inputs.home-manager.follows = "home-manager";
    };
  };

  perSystem =
    { pkgs, system, ... }:
    {
      devshells.default = {
        devshell.packages = secretPackages pkgs system;
      };
    };

  flake.nixosModules.ragenix =
    { pkgs, ... }:
    {
      imports = [ inputs.ragenix.nixosModules.default ];

      age.ageBin = "${pkgs.rage}/bin/rage";
      age.secretsDir = "/run/secrets";

      environment.systemPackages = secretPackages pkgs pkgs.stdenv.hostPlatform.system;

      age.secrets.hello-secret = {
        file = ../../secrets/hello-secret.age;
        mode = "0444";
      };

      # Ensure pinentry can bind to the current TTY and define Fish wrappers for ragenix and rage
      environment.interactiveShellInit = ''
        export GPG_TTY=$(tty)
      '';
      programs.fish.interactiveShellInit = ''
        set -gx GPG_TTY (tty)

        function ragenix --description 'ragenix wrapper passing default ~/.config/age/identities'
            if test -f $HOME/.config/age/identities
                command ragenix -i $HOME/.config/age/identities $argv
            else
                command ragenix $argv
            end
        end

        function rage --description 'rage wrapper passing default ~/.config/age/identities'
            if test -f $HOME/.config/age/identities
                command rage -i $HOME/.config/age/identities $argv
            else
                command rage $argv
            end
        end
      '';
    };
}
