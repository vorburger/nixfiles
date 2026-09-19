# YubiKey PAM U2F

This page documents how to configure and register your YubiKey for passwordless `sudo` authentication using U2F (FIDO2).

## Setup & Registration

Ensure your NixOS configuration has the `pam-u2f` module enabled. To register your YubiKey to your user account, you must generate a mapping file using the `pamu2fcfg` utility:

1. Connect your YubiKey to the system.
2. Create the directory for the config files:

   ```bash
   mkdir -p ~/.config/Yubico
   ```

3. Run the following command to output the key configuration and press/touch the flashing YubiKey when prompted:

   ```bash
   pamu2fcfg > ~/.config/Yubico/u2f_keys
   ```

If it's asking to `Enter PIN for /dev/hidraw2`, this is the YK's FIDO2 Applet PIN.
That's the same PIN as the one which you set in a Web Browser for using WebAuthn with this YK.
(See `ykman fido info`, so same PIN as `ykman fido access verify-pin`, change via `ykman fido access change-pin`.)

### Registering Multiple Keys

If you have backup YubiKeys, you can append them to the same file using:

```bash
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

_(Note: The `-n` option ensures that the username prefix is not repeated, as `pamu2fcfg` will append the new key configuration to the existing user entry)._

---

## Configuration Options

The U2F configuration is handled by `modules/services/pam-u2f.nix`, which enables `pam_u2f` specifically for `sudo`, `polkit-1` (GUI privilege escalation prompts), and `systemd-run0` (keeping initial GDM login and screen unlock password-protected).

- `security.pam.u2f.control = "sufficient"`: Setting the control rule to `sufficient` ensures that a successful YubiKey touch is enough on its own to authenticate privilege requests, bypassing the password prompt.
- `security.pam.u2f.settings.cue = true`: This displays a cue message (`Please touch the device.`) during CLI authentication so you know when to press the key.

---

## SSH Authentication (FIDO2 / U2F)

Modern OpenSSH natively supports FIDO2/U2F hardware tokens (YubiKeys) via security key (`-sk`) key types, without requiring GnuPG or `scdaemon`.

### Generating a Key

Generate a hardware-backed key on your YubiKey:

```bash
ssh-keygen -t ecdsa-sk -f ~/.ssh/id_ecdsa_sk
```

Touch the flashing YubiKey when prompted. Then copy `~/.ssh/id_ecdsa_sk.pub` to GitHub (`https://github.com/settings/keys`) or your target server's `authorized_keys`.

### Declarative Client Configuration

The SSH client configuration is managed declaratively via Home Manager in `modules/users/_vorburger.nix`:

```nix
programs.ssh = {
  enable = true;
  enableDefaultConfig = false;
  settings = {
    "github.com" = {
      identityFile = "~/.ssh/id_ecdsa_sk";
    };
  };
};
```

> [!NOTE]
> `IdentitiesOnly yes` is intentionally **not** set here. This allows SSH Agent Forwarding (`ssh -A`) to work seamlessly: when connecting remotely from another host (e.g. `ixo`), OpenSSH offers forwarded agent keys first. When logged in locally at the machine with the YubiKey inserted, OpenSSH falls back to `~/.ssh/id_ecdsa_sk`.

### Legacy GnuPG SSH Agent Deprecation

Previously, YubiKeys were used for SSH via GnuPG's OpenPGP authentication subkey (`programs.gnupg.agent.enableSSHSupport = true`). This legacy approach is deprecated and disabled in this repository:

- Native OpenSSH `-sk` keys communicate directly with the token via `libfido2`, avoiding `scdaemon` CCID lock contention with other applications.
- Password store (`pass`) and Git commit signing (`git commit -S`) operate via GnuPG's encryption and signing sockets (`S.gpg-agent`), which do not require or use GnuPG's SSH agent socket (`S.gpg-agent.ssh`).
