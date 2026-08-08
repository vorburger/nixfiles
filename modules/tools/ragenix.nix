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
        file = ../../encrypted/hello-secret.age;
        mode = "0444";
      };

      # Ensure pinentry can bind to the current TTY and define Fish wrappers for ragenix, rage, and pass
      environment.interactiveShellInit = ''
        export GPG_TTY=$(tty)
      '';
      programs.fish.interactiveShellInit = ''
        set -gx GPG_TTY (tty)

        # Force using only nano as editor, because e.g. VSC (code) may leak secrets to AI APIs.

        function pass --description 'pass wrapper ensuring nano is always used as editor'
            EDITOR=nano VISUAL=nano command pass $argv
        end

        function ragenix --description 'ragenix wrapper passing default ~/.config/age/identities and using nano editor'
            if test -f $HOME/.config/age/identities
                echo "(ragenix wrapper automatically using -i $HOME/.config/age/identities)" >&2
                EDITOR=nano VISUAL=nano command ragenix -i $HOME/.config/age/identities $argv
            else
                EDITOR=nano VISUAL=nano command ragenix $argv
            end
        end

        function raged --description 'rage decryption helper passing default ~/.config/age/identities'
            if test -f $HOME/.config/age/identities
                command rage -d -i $HOME/.config/age/identities $argv
            else
                echo "raged: Error: identity file $HOME/.config/age/identities does not exist" >&2
                return 1
            end
        end
      '';
    };
}
