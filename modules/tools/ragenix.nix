{ inputs, lib, ... }:
let
  identitiesData = import ../../secrets/identities.nix;

  # Filter identities for the host:
  # - Host-specific identities (e.g. titan-yubikey-*, ixo-tpm) deployed ONLY on their matching host.
  # - Portable identities (e.g. portable-yubikey-*) deployed on all hosts, but placed AFTER host-specific ones.
  hostIdentitiesText =
    hostName:
    let
      hostSpecific = lib.filterAttrs (
        name: _: lib.hasPrefix "${hostName}-" name
      ) identitiesData.identities;
      portable = lib.filterAttrs (name: _: lib.hasPrefix "portable-" name) identitiesData.identities;
      orderedValues = builtins.attrValues hostSpecific ++ builtins.attrValues portable;
    in
    builtins.concatStringsSep "\n\n" orderedValues;

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
  # rust-overlay is explicitly declared here and followed by ragenix because
  # upstream yaxitech/ragenix locks an older rust-overlay in its flake.lock.
  # When ragenix follows our nixpkgs (where stdenv.isLinux / stdenv.isDarwin was
  # deprecated and removed from stdenv), the older rust-overlay failed during evaluation
  # with `error: attribute 'isLinux' missing at lib/mk-aggregated.nix`.
  # Forcing ragenix to follow the latest rust-overlay fixes this compatibility issue.
  flake-file.inputs.rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # We import ragenix from github:yaxitech/ragenix rather than using pkgs.ragenix
  # from nixpkgs because nixpkgs only provides the ragenix CLI binary, whereas the
  # upstream flake provides inputs.ragenix.nixosModules.default (the NixOS module
  # providing age.* configuration and secret decryption activation services).
  flake-file.inputs.ragenix = {
    url = "github:yaxitech/ragenix";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      agenix.inputs.home-manager.follows = "home-manager";
      flake-utils.inputs.systems.follows = "ragenix/agenix/systems";
      rust-overlay.follows = "rust-overlay";
    };
  };

  perSystem =
    { pkgs, system, ... }:
    {
      devshells.default = {
        devshell.packages = secretPackages pkgs system;
      };

      apps.write-recipients = {
        type = "app";
        program =
          let
            script = pkgs.writeShellScriptBin "write-recipients" ''
              set -euo pipefail
              ROOT_DIR="$(git rev-parse --show-toplevel)"
              RECIPIENTS_FILE="$ROOT_DIR/secrets/recipients.nix"

              echo "Dynamically deriving recipients from secrets/identities.nix..."

              # 1. Export JSON map of identities and hostKeys from identities.nix
              nix-instantiate --eval --strict --json -E '(import "'"$ROOT_DIR"'/secrets/identities.nix")' > "$ROOT_DIR/scratch_identities.json"

              # 2. Process each identity using age-plugin-tpm -y, comments, or host keys
              PYTHON_PARSER='
              import json, sys, subprocess, re

              data = json.load(open("'$ROOT_DIR'/scratch_identities.json"))
              identities = data.get("identities", {})
              host_keys = data.get("hostKeys", {})
              recipients = {}

              for name, text in identities.items():
                  rec = None
                  # First try extracting from comment block (# Recipient: age1...)
                  m = re.search(r"#\s*Recipient:\s*(age1[a-z0-9]+)", text, re.IGNORECASE)
                  if m:
                      rec = m.group(1)
                  else:
                      # Run age-plugin-tpm -y to convert TPM identities dynamically
                      try:
                          res = subprocess.run(
                              ["${pkgs.age-plugin-tpm}/bin/age-plugin-tpm", "-y", "--tpm-recipient", "-o", "-"],
                              input=text.encode(),
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              check=True
                          )
                          rec = res.stdout.decode().strip()
                      except Exception:
                          rec = None
                  recipients[name] = rec

              # Add host SSH public keys directly
              for name, key in host_keys.items():
                  recipients[name] = key

              json.dump(recipients, open("'$ROOT_DIR'/scratch_recipients.json", "w"))
              '

              ${pkgs.python3}/bin/python3 -c "$PYTHON_PARSER"
              rm -f "$ROOT_DIR/scratch_identities.json"

              # Fail-fast validation: Ensure no key evaluated to null or empty
              NULL_KEYS="$(${pkgs.jq}/bin/jq -r 'to_entries[] | select(.value == null or .value == "") | .key' "$ROOT_DIR/scratch_recipients.json")"

              if [ -n "$NULL_KEYS" ]; then
                echo "ERROR: Could not derive recipient public keys for the following identities in secrets/identities.nix:" >&2
                echo "$NULL_KEYS" | sed 's/^/  - /' >&2
                echo "" >&2
                echo "Please ensure TPM identities can be converted via age-plugin-tpm or identities contain a '# Recipient: age1...' comment block." >&2
                rm -f "$ROOT_DIR/scratch_recipients.json"
                exit 1
              fi

              cat <<'EOF' > "$RECIPIENTS_FILE"
              # Auto-generated by `nix run .#write-recipients` - DO NOT EDIT MANUALLY
              # Derived dynamically from secrets/identities.nix
              {
                recipients = {
              EOF

              ${pkgs.jq}/bin/jq -r 'to_entries | sort_by(.key)[] | "    \(.key) = \"\(.value)\";"' "$ROOT_DIR/scratch_recipients.json" >> "$RECIPIENTS_FILE"
              rm -f "$ROOT_DIR/scratch_recipients.json"

              cat <<'EOF' >> "$RECIPIENTS_FILE"
                };
              }
              EOF
              echo "Wrote $RECIPIENTS_FILE cleanly."
            '';
          in
          "${script}/bin/write-recipients";
      };
    };

  flake.nixosModules.ragenix =
    { pkgs, config, ... }:
    let
      identitiesText = hostIdentitiesText config.networking.hostName;
      identitiesFile = pkgs.writeText "age-identities" identitiesText;
    in
    {
      imports = [ inputs.ragenix.nixosModules.default ];

      age.ageBin = "${pkgs.rage}/bin/rage";
      age.secretsDir = "/run/secrets";

      environment.systemPackages = secretPackages pkgs pkgs.stdenv.hostPlatform.system;

      # Automatically provision ~/.config/age/identities for all system users
      environment.etc."skel/.config/age/identities".source = identitiesFile;

      # Also ensure root / active default environment has the identity file deployed cleanly without heredocs
      system.activationScripts.deployAgeIdentities = {
        text = ''
          # Provision ~/.config/age/identities for all user home directories
          for udir in /home/*; do
            if [ -d "$udir" ]; then
              user="$(stat -c '%U:%G' "$udir")"
              mkdir -p "$udir/.config/age"
              cp -f ${identitiesFile} "$udir/.config/age/identities"
              chmod 0600 "$udir/.config/age/identities"
              chown -R "$user" "$udir/.config"
            fi
          done
        '';
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
                echo "(ragenix wrapper automatically using --rules secrets/rules.nix -i $HOME/.config/age/identities)" >&2
                EDITOR=nano VISUAL=nano command ragenix --rules secrets/rules.nix -i $HOME/.config/age/identities $argv
            else
                EDITOR=nano VISUAL=nano command ragenix --rules secrets/rules.nix $argv
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
