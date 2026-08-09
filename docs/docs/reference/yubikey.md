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
