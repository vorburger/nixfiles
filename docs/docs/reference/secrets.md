# Secrets Management in nixfiles

This document explains the secrets management architecture in `nixfiles` using [`ragenix`](https://github.com/yaxitech/ragenix) (a Rust-based re-implementation of `agenix` powered by `rage`).

For lower-level commands and key generation details for `rage`, TPM, and YubiKey, see [Age Documentation](age.md).

---

## Architecture Principles

1. **No Cleartext in `/nix/store` or Git**: Cleartext secret values **never** enter the world-readable `/nix/store` or the public Git repository. Only encrypted `.age` files are tracked in Git and evaluated into `/nix/store`.
2. **Runtime RAM Decryption**: During NixOS system activation/boot, secrets are decrypted into a temporary RAM filesystem (`/run/secrets/<name>`) with strict ownership (`0400` / `0444`) and cleared on reboot.
3. **Automatic Identity Provisioning**: Decryption identity handles (YubiKey and host-specific TPM handle stubs) are stored in `secrets/identities.nix` and automatically deployed to `~/.config/age/identities` on every NixOS system during activation.
4. **Host Isolation for TPM Keys**: Machine-sealed TPM identity handles (`*-tpm`) are deployed _only_ to their matching host, preventing `age-plugin-tpm` unsealing errors on other machines. Global identities (YubiKeys) are deployed everywhere.
5. **Machine-Readable Keys**: Keys are named (`portable-yubikey-9599730`, `ixo-tpm`, `ixo`, etc.) in `secrets/identities.nix` and `secrets/recipients.nix`, allowing structured key management.
6. **Forever Access (Multi-Recipient Encryption)**: To prevent loss of access if a machine disk is lost or reinstalled (invalidating `/etc/ssh/ssh_host_ed25519_key`), every secret file is encrypted to **both**:
   - **Host Keys**: Raw OpenSSH host public key strings (`ssh-ed25519 AAAAC3...`) from `/etc/ssh/ssh_host_ed25519_key.pub` for unattended system boot decryption.
   - **Master / Admin Keys**: Your personal YubiKey address (`age1yubikey...`) or personal TPM public key.

---

## 1. Directory Structure & Key Definitions

Secret management is grouped in the `secrets/` directory:

```
secrets/
├── identities.nix       # Human-edited identity handles & OpenSSH host keys
├── recipients.nix       # Auto-generated recipient map (nix run .#write-recipients)
├── rules.nix            # Assigns .age files to public recipient keys
└── encrypted/           # Encrypted .age secret files
    └── hello-secret.age
```

- **`secrets/identities.nix`**: Human-edited source of truth containing named decryption identity handles (`portable-yubikey-9599730`, `ixo-tpm`) and OpenSSH host keys (`ixo`, `titan`).
- **`secrets/recipients.nix`**: Auto-generated recipient map (`nix run .#write-recipients`) imported by `secrets/rules.nix`.
- **`secrets/rules.nix`**: Evaluated by `ragenix` (`ragenix --rules secrets/rules.nix`).

To regenerate `recipients.nix` dynamically after editing `secrets/identities.nix`:

```bash
nix run .#write-recipients
```

### `secrets/rules.nix`

`secrets/rules.nix` imports `recipients.nix` and assigns public recipient keys to encrypted files:

```nix
let
  keys = (import ./recipients.nix).recipients;
in
{
  "encrypted/hello-secret.age".publicKeys = builtins.attrValues keys;
}
```

---

## 2. Onboarding a New Host (e.g. `titan`)

When setting up a brand-new host machine (`titan`), system activation during `nixos-rebuild switch` will initially fail to decrypt secrets if `titan`'s host SSH key has not yet been added to `secrets/identities.nix` and re-encrypted into the `.age` files.

Follow these onboarding steps on the new host (with your YubiKey plugged in):

### Step 1: Add the Host's SSH Public Key to `secrets/identities.nix`

On the new host (`titan`), view its SSH host public key:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

_(If the file does not exist yet, generate it via `sudo ssh-keygen -A`)._

Add the public key to `hostKeys` inside `secrets/identities.nix`:

```nix
  hostKeys = {
    ixo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPobJWkfYiOfQ/dfIz6HYY9LooERxuxXBQGE+oBxQpPH";
    titan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."; # titan host key
  };
```

### Step 2: Manually Copy `secrets/identities.nix` to `~/.config/age/identities`

Before `nixos-rebuild switch` runs successfully for the first time, `~/.config/age/identities` is not yet deployed by NixOS system activation.

Manually copy the identity handles text (or your YubiKey handle) into `~/.config/age/identities`:

```bash
mkdir -p ~/.config/age
# Copy the YubiKey identity handle block from secrets/identities.nix
cat <<'EOF' > ~/.config/age/identities
# Recipient: age1yubikey1qd5rn4s8d04pjkhqe4xq8nspc883gm7jnnk3pucsr33yg6eq00v9uq5tsas
AGE-PLUGIN-YUBIKEY-17FAFYQYZ4MD0W7CZP5JUV
EOF
chmod 0600 ~/.config/age/identities
```

### Step 3: Regenerate Recipients & Rekey Secrets

Run the recipient generator and rekey the secret files using explicit flags (`--rules` and `-i`):

```bash
nix run .#write-recipients
ragenix --rules secrets/rules.nix -i ~/.config/age/identities --rekey
```

When prompted for your YubiKey PIN and touch, `ragenix` will decrypt the `.age` secret files and re-encrypt them with `titan`'s new host key added to the recipient list.

### Step 4: Commit and Switch

Commit the updated `secrets/identities.nix`, `secrets/recipients.nix`, and `secrets/encrypted/*.age` files to git, and complete the switch:

```bash
nixos-rebuild switch
```

System activation will now decrypt `/run/secrets/*` cleanly using `/etc/ssh/ssh_host_ed25519_key`!

---

## 3. Managing Secrets with `ragenix` CLI

`ragenix` CLI is available in the default `devShell` and on all NixOS hosts running `nixfiles`.

### Create or Edit a Secret File

```bash
ragenix -e secrets/encrypted/hello-secret.age
```

This opens your `$EDITOR` securely, allowing you to edit the secret in cleartext. Upon saving, it re-encrypts the file automatically using the keys in `secrets/rules.nix`.

> **Note on User Identities and `ragenix` wrapper**:
> The `ragenix` Fish shell alias automatically passes `--rules secrets/rules.nix` and `-i $HOME/.config/age/identities` if available.
>
> **Why `rage` remains unaliased**: Encryption commands (`rage -e -r ...`) **cannot** receive `-i` identity files, as identity files contain private key material meant only for decryption. (Passing `-i` during encryption causes plugins like `age-plugin-tpm` to crash, see [Foxboron/age-plugin-tpm#46](https://github.com/Foxboron/age-plugin-tpm/issues/46)). `rage` is kept unaliased so standard `rage -e` encryption commands operate cleanly.
>
> **`raged` Decryption Shortcut**: For quick standalone decryption using your default `~/.config/age/identities` file, you can use the `raged` Fish alias (`raged secret.txt.age`), which automatically passes `-d -i $HOME/.config/age/identities`.

### Rekeying Secrets (e.g. after adding a new host key)

When a new host key or master key is added to `secrets/identities.nix`:

1. Run `nix run .#write-recipients` to update `secrets/recipients.nix`.
2. Run `ragenix --rekey`.

---

## 4. Using Secrets in NixOS Modules

Import `ragenix` via `self.nixosModules.ragenix` (or automatically via `modules/hosts/_common.nix`).

In your NixOS module (e.g., `modules/services/hello.nix`):

```nix
age.secrets.hello-secret = {
  file = ../../secrets/encrypted/hello-secret.age;
  mode = "0444";
};
```

NixOS will automatically decrypt the file to `/run/secrets/hello-secret` at runtime.

---

## 5. Demo: `h` CLI

The `h` CLI tool (`modules/packages/h.nix`) checks for `/run/secrets/hello-secret`:

```bash
$ h
hello, world
hello, secret
```

---

## References

- [Ragenix GitHub Repository](https://github.com/yaxitech/ragenix)
- [Age Documentation](age.md)
