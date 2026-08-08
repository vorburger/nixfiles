# Secrets Management in nixfiles

This document explains the secrets management architecture in `nixfiles` using [`ragenix`](https://github.com/yaxitech/ragenix) (a Rust-based re-implementation of `agenix` powered by `rage`).

For lower-level commands and key generation details for `rage`, TPM, and YubiKey, see [Age Documentation](age.md).

---

## Architecture Principles

1. **No Cleartext in `/nix/store` or Git**: Cleartext secret values **never** enter the world-readable `/nix/store` or the public Git repository. Only encrypted `.age` files are tracked in Git and evaluated into `/nix/store`.
2. **Runtime RAM Decryption**: During NixOS system activation/boot, secrets are decrypted into a temporary RAM filesystem (`/run/secrets/<name>`) with strict ownership (`0400` / `0444`) and cleared on reboot.
3. **Forever Access (Multi-Recipient Encryption)**: To prevent loss of access if a machine disk is lost or reinstalled (invalidating `/etc/ssh/ssh_host_ed25519_key`), every secret file is encrypted to **both**:
   - **Host Keys**: Raw OpenSSH host public key strings (`ssh-ed25519 AAAAC3...`) from `/etc/ssh/ssh_host_ed25519_key.pub` for unattended system boot decryption.
   - **Master / Admin Keys**: Your personal YubiKey address (`age1yubikey...`) or personal TPM public key.

---

## 1. Root `secrets.nix` & Secret Rules

Secret rules are defined in `secrets.nix` at the repository root:

```nix
let
  # Host SSH public keys (use raw `ssh-ed25519 AAAAC3...` string)
  ixoHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPobJWkfYiOfQ/dfIz6HYY9LooERxuxXBQGE+oBxQpPH";

  # Admin / Master recovery keys (Personal TPM key - use age1tpm1... format due to yaxitech/ragenix#170)
  userMasterKey = "age1tpm1qt0wrxgpsmxq6s29wydwrc4hedg3mpn6utl5e8adrnmau5f4udghvs66e5k";

  allHosts = [ ixoHostKey userMasterKey ];
in
{
  "encrypted/hello-secret.age".publicKeys = allHosts;
}
```

---

## 2. Managing Secrets with `ragenix` CLI

`ragenix` CLI is available in the default `devShell` and on all NixOS hosts running `nixfiles`.

### Create or Edit a Secret File

```bash
ragenix -e encrypted/hello-secret.age
```

This opens your `$EDITOR` securely, allowing you to edit the secret in cleartext. Upon saving, it re-encrypts the file automatically using the keys in `secrets.nix`.

> **Note on User Identities in `nixfiles`**:
> Standard `ragenix` requires passing `-i /path/to/identity` when decrypting if your user identity isn't stored in default SSH key paths.
>
> In this repository's `nixfiles` environment, interactive Fish shell startup automatically defines a wrapper function for `ragenix` that passes `-i $HOME/.config/age/identities` if that file exists. This allows non-root user shell execution of `ragenix -e` and `ragenix --rekey` without needing `sudo` or manual `-i` arguments.
>
> **Why `rage` remains unaliased**: Encryption commands (`rage -e -r ...`) **cannot** receive `-i` identity files, as identity files contain private key material meant only for decryption. (Passing `-i` during encryption causes plugins like `age-plugin-tpm` to crash, see [Foxboron/age-plugin-tpm#46](https://github.com/Foxboron/age-plugin-tpm/issues/46)). `rage` is kept unaliased so standard `rage -e` encryption commands operate cleanly.

### Rekeying Secrets (e.g. after adding a new host key)

When a new host key or master key is added to `secrets.nix`:

```bash
ragenix --rekey
```

---

## 3. Using Secrets in NixOS Modules

Import `ragenix` via `self.nixosModules.ragenix` (or automatically via `modules/hosts/_common.nix`).

In your NixOS module (e.g., `modules/services/hello.nix`):

```nix
age.secrets.hello-secret = {
  file = ../../encrypted/hello-secret.age;
  mode = "0444";
};
```

NixOS will automatically decrypt the file to `/run/secrets/hello-secret` at runtime.

---

## 4. Demo: `h` CLI

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
