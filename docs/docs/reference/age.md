# Secrets Management with Age / Rage

This document outlines basic "Hello, World" usage for encrypting and decrypting secrets using [`rage`](https://github.com/str4d/rage) (a Rust implementation of `age`) with various identity and recipient types.

---

## Key Terminology

To avoid confusion when using `age` and `rage`:

- **Identity File** (`-i <file>`): Represents the **Identity** / key reference payload (`*-identity.txt` or `private-key.txt`). Used for **decryption**.
- **Recipient File** (`-R <file>`) or **Recipient Address** (`-r <address>`): Contains one or more **Public Keys** (`tpm-public-key.txt`, `yubikey-public-key.txt`). Used for **encryption**.

> **Standard Identity File Location (`~/.config/age/identities`)**:
> `rage` and `age` CLI tools require passing explicit `-i /path/to/identity` arguments for custom key locations.
> A common community convention is to append your user private key handles (such as TPM identities or YubiKey stubs) into `~/.config/age/identities`.
>
> In this repository's `nixfiles` environment, interactive Fish shell startup defines wrapper functions for `ragenix` and `rage` that pass `-i $HOME/.config/age/identities` if that file exists, enabling non-root CLI usage without manual `-i` flags.

---

## SSH Host Keys & `age` vs `rage`

When using SSH host keys (`/etc/ssh/ssh_host_ed25519_key`) as decryption identities:

1. **`age` (Go implementation)**: Supports raw OpenSSH public keys (`ssh-ed25519 AAAAC3...`) directly as recipients (`-r "ssh-ed25519 AAAAC3..."`) and decrypts natively with `-i /etc/ssh/ssh_host_ed25519_key`.
2. **`ragenix` / `agenix`**: Configures `secrets.nix` with raw `ssh-ed25519 AAAAC3...` public key strings. During system activation, `ragenix` uses `age`/`rage` to decrypt `/run/secrets/` directly using the system host key.
3. **`ssh-to-age`**: Converts an OpenSSH public key into a native X25519 `age1...` address. Note that converting to `age1...` recipient format requires converting the private key with `ssh-to-age -k` for manual decryption via `rage -d`. Using raw `ssh-ed25519 AAAAC3...` strings in `secrets.nix` is the standard convention for NixOS activation.

---

## 1. Passphrase Encryption

Passphrase-based encryption prompts for a password interactively during encryption and decryption. No key files or hardware tokens are required.

> **Note on `pinentry` & Terminal Passphrase Prompts**:
> When `rage -p` runs, it invokes `pinentry` by default. In terminal environments (such as GNOME Console, Kitty, or TMUX), `pinentry-curses` may hang or fail to capture keyboard input.
>
> To bypass `pinentry` and enter the passphrase directly in your terminal, set `PINENTRY_PROGRAM=""`:
>
> ```bash
> PINENTRY_PROGRAM="" rage -p -o secret.txt.age secret.txt
> ```

### Encrypt

Create a test file and encrypt it:

```bash
echo 'hello, secret' > secret.txt
rage -p -o secret.txt.age secret.txt
```

### Decrypt

```bash
rage -d secret.txt.age
```

---

## 2. Private Key File

Generate a standard X25519 key pair stored in local files.

> **Note on Post-Quantum (PQ) Encryption**: Standard `rage-keygen` generates X25519 key pairs (Curve25519 ECC), which are **not** post-quantum safe. Native post-quantum support (`-pq`) is being developed in unreleased `rage` upstream PRs (#590).

### Key Generation

Generate the private key file and derive the public recipient file:

```bash
rage-keygen -o private-key.txt
rage-keygen -y private-key.txt > public-key.txt
```

### Encrypt

Encrypt using the recipient public key file (`-R`):

```bash
rage -R public-key.txt -o secret.txt.age secret.txt
```

### Decrypt

Decrypt using the private key file (`-i`):

```bash
rage -d -i private-key.txt secret.txt.age
```

---

## 3. TPM (Trusted Platform Module)

`age-plugin-tpm` stores key material sealed inside the local system's TPM 2.0 hardware module.

> **Note on Post-Quantum Safety**: TPM 2.0 ECC (P-256 / RSA) key storage is **not** post-quantum safe.

### Key Generation

Generate the TPM identity file sealed with a PIN/passphrase (`-g -p`) and convert it to a recipient public key (`-y` reading from input file `-o`):

```bash
age-plugin-tpm -g -p -o tpm-identity.txt
# Export recipient in age1tpm1... format (required for ragenix due to https://github.com/yaxitech/ragenix/issues/170)
age-plugin-tpm --tpm-recipient -y -o tpm-public-key.txt tpm-identity.txt
```

> **Important Note for `ragenix` / `secrets.nix`**:
> When generating TPM recipient public keys for use in `secrets.nix`, always use `age-plugin-tpm --tpm-recipient -y ...` to export the recipient in `age1tpm1...` format. The default `age1tag1...` (`p256tag`) format is currently not handled correctly during `ragenix` rekeying ([yaxitech/ragenix#170](https://github.com/yaxitech/ragenix/issues/170)).

> **PIN / Passphrase Security Requirement**:
> Always supply the `-p` / `--pin` flag when generating a TPM key. Without `-p`, any unprivileged process running under your user shell could silently ask the TPM chip to unseal and decrypt age secrets. With `-p`, `age-plugin-tpm` triggers a graphical/terminal `pinentry` prompt requiring human confirmation before the TPM releases the key.

**How identity files work & System Wipes**:

- `tpm-identity.txt` contains a sealed key blob payload bound to your system's TPM 2.0.
- If your machine is completely wiped and NixOS is re-installed, as long as you back up `tpm-identity.txt` **and** the hardware TPM chip was not reset in BIOS/UEFI, `tpm-identity.txt` can still be unsealed and decrypted on the fresh NixOS installation.
- If the TPM chip is cleared/reset in BIOS/UEFI, `tpm-identity.txt` becomes permanently unrecoverable.

### Encrypt

Using the generated public recipient file (`-R`):

```bash
rage -R tpm-public-key.txt -o secret.txt.age secret.txt
```

### Decrypt

```bash
rage -d -i tpm-identity.txt secret.txt.age
```

---

## 4. YubiKey

`age-plugin-yubikey` manages age identity keys stored inside a physical YubiKey's PIV slot.

> **Note on Post-Quantum Safety**: YubiKey PIV slots use RSA / ECC (P-256, Ed25519) and are **not** post-quantum safe.

### Key Generation

Insert your YubiKey and generate a new identity key, then print its recipient address:

```bash
age-plugin-yubikey --generate
age-plugin-yubikey --identity > yubikey-identity.txt
age-plugin-yubikey --list > yubikey-public-key.txt
```

**How identity files work & System Wipes**:

- `yubikey-identity.txt` contains a stub reference (serial number, slot, public key) pointing to the secret key stored securely inside the physical YubiKey.
- If your OS is wiped and re-installed, backing up `yubikey-identity.txt` (or re-running `age-plugin-yubikey --identity`) will allow you to decrypt files on the new installation using the same physical YubiKey.

### Encrypt

`age-plugin-yubikey` outputs age recipient addresses (`age1yubikey1...`). Encrypt using `-r` with the recipient address (or `-R` with a recipient file containing `age1yubikey...` addresses):

```bash
rage -r $(cat yubikey-public-key.txt) -o secret.txt.age secret.txt
```

### Decrypt

```bash
rage -d -i yubikey-identity.txt secret.txt.age
```

When decrypting, `rage` will prompt for your YubiKey PIN and require physical touch on the YubiKey hardware button.
