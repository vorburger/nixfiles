# Secrets Management in nixfiles

This document explains the secrets management architecture in `nixfiles` using [`ragenix`](https://github.com/yaxitech/ragenix) (a Rust-based re-implementation of `agenix` powered by `rage`).

For lower-level commands and key generation details for `rage`, TPM, and YubiKey, see [Age Documentation](age.md).

---

## Architecture Principles

1. **No Cleartext in `/nix/store` or Git**: Cleartext secret values **never** enter the world-readable `/nix/store` or the public Git repository. Only encrypted `.age` files are tracked in Git and evaluated into `/nix/store`.
2. **Runtime RAM Decryption**: During NixOS system activation/boot, secrets are decrypted into a temporary RAM filesystem (`/run/secrets/<name>`) with strict ownership (`0400` / `0444`) and cleared on reboot.
3. **Automatic Identity Provisioning**: Decryption identity handles (YubiKey and host-specific TPM handle stubs) are stored in `secrets/identities.nix` and automatically deployed to `~/.config/age/identities` on every NixOS system during activation.
4. **Host Filtering & Identity Ordering**: Host-specific identity handles (`<host>-*`, e.g. `ixo-tpm` or `titan-yubikey-10300902`) are deployed _only_ to their matching host, avoiding unnecessary plugin errors or prompts. Portable identities (`portable-yubikey-*`) are deployed to all hosts, but placed AFTER host-specific ones in `~/.config/age/identities`.
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

`secrets/rules.nix` dynamically collects `flake.secretRules` declarations defined across `modules/**/*.nix` (e.g., `modules/packages/h.nix`). Feature modules can use the `mkSecret` helper (`lib/mk-secret.nix`) to declare their secrets and rules compactly:

```nix
let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
in
mkSecret {
  name = "hello";
  moduleName = "h";
  mode = "0444";
}
```

When evaluated by `ragenix`, `secrets/rules.nix` imports `recipients.nix` and merges all secret recipient rules (defaulting to encrypting to all `recipients`).

---

## 2. Adding a New Key

1. Pull out any other previous YK
1. Generate Key Identity; e.g. `age-plugin-yubikey`
1. Edit `secrets/identities.nix` to add it in there
1. Run `nix run .#write-recipients` to update `secrets/recipients.nix`
1. Plug in previous registered YK (so now BOTH YKs are in)
1. Run `ragenix --rekey` to update all `secrets/encrypted/*.age`, type PIN of previous YK
1. Pull out any other previous YK
1. Commit: `git commit -a -m "secrets: Add 🔑 Key"`
1. Switch: `nh os switch .`
1. Test with `raged secrets/encrypted/hello-secret.age`
1. Test with `h`
1. Push

## 3. Onboarding a New Host (e.g. `titan`)

When setting up a brand-new host machine (`titan`), system activation during `nixos-rebuild switch` will initially fail to decrypt secrets if `titan`'s host SSH key has not yet been added to `secrets/identities.nix` and re-encrypted into the `.age` files.

### Recommended Method: Onboard from an Existing Active Workstation (e.g. `ixo`)

If you have an existing active machine (`ixo`) where your YubiKey is plugged in:

1. **Get Host Key on `titan` (via SSH)**:

   ```bash
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. **Add Key & Rekey on `ixo`**:
   Add `titan = "ssh-ed25519 AAAAC3...";` to `secrets/identities.nix` on `ixo`.

   ```bash
   nix run .#write-recipients
   ragenix --rekey
   git commit -am "secrets: Add titan host key" && git push
   ```

3. **Switch on `titan` (via SSH)**:

   ```bash
   git pull && nixos-rebuild switch
   ```

---

### Standalone Method: Direct Onboarding on `titan` (YubiKey plugged directly into `titan`)

If no other active workstation is up and running, you can onboard directly on `titan` with your YubiKey plugged into `titan`:

1. **Add `titan`'s Host SSH Key**:
   View `cat /etc/ssh/ssh_host_ed25519_key.pub` and add it to `hostKeys` in `secrets/identities.nix`.

2. **Manually Provision `~/.config/age/identities`**:
   Before initial `switch`, manually copy your YubiKey identity handle block into `~/.config/age/identities`:

   ```bash
   mkdir -p ~/.config/age
   cat <<'EOF' > ~/.config/age/identities
   # Recipient: age1yubikey1qd5rn4s8d04pjkhqe4xq8nspc883gm7jnnk3pucsr33yg6eq00v9uq5tsas
   AGE-PLUGIN-YUBIKEY-17FAFYQYZ4MD0W7CZP5JUV
   EOF
   chmod 0600 ~/.config/age/identities
   ```

3. **Resolve Smartcard Locks (if accessing over SSH)**:
   If accessing `titan` remotely over SSH while the YubiKey is plugged into `titan`, ensure `gpg-agent` / `scdaemon` has not exclusively locked the card:

   ```bash
   gpgconf --kill gpg-agent || true
   sudo systemctl restart pcscd
   ```

4. **Regenerate Recipients & Rekey Secrets**:
   Run with explicit flags (`--rules` and `-i`):

   ```bash
   nix run .#write-recipients
   ragenix --rules secrets/rules.nix -i ~/.config/age/identities --rekey
   ```

5. **Commit and Switch**:

   ```bash
   git commit -am "secrets: Add titan host key"
   nixos-rebuild switch
   ```

---

## 4. Managing Secrets with `ragenix` CLI

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

## 5. Using Secrets in NixOS Modules

Import `ragenix` via `self.nixosModules.ragenix` (or automatically via `modules/hosts/_common.nix`).

In your module (e.g., `modules/packages/h.nix`), use `mkSecret` (`lib/mk-secret.nix`):

```nix
let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
in
mkSecret {
  name = "hello";
  moduleName = "h";
  mode = "0444";
}
```

NixOS will automatically decrypt the file to `/run/secrets/hello` at runtime.

---

## 6. Demo: `h` CLI

The `modules/packages/h.nix` defines `flake.nixosModules.h` (which registers `age.secrets.hello-secret`) and provides the `h` CLI command which checks for `/run/secrets/hello-secret`:

```bash
$ h
hello, world
hello, secret
```

---

## References

- [Ragenix GitHub Repository](https://github.com/yaxitech/ragenix)
- [Age Documentation](age.md)
