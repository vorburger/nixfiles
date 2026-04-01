# `ssh-tpm-keygen`

## Passphrase

DO set a passphrase, and do NOT leave it empty - EVEN though the private key is in the TPM.

This is especially important since `ssh-tpm-agent` [does not yet support using PCRs](https://github.com/Foxboron/ssh-tpm-agent/issues/15) (`systemd-analyze pcrs`).

This passphrase is per "session", so you won't have to keep typing it every time.

For more security, opt for a "requires presence confirmation with touch" model. This does not appear to be supported by `ssh-tpm-agent`; consider using a physical YubiKey (or similar), e.g. with [ `yubikey-agent`](https://github.com/FiloSottile/yubikey-agent).

## Setup

Make sure your Nix user has `tss` in their `extraGroups`.
Remember to **hard reboot** for such group changes to take effect.
Doing a simple logout and login again will have `groups` show
you as being in `tss` - but your systemd user-level unit still
will not access to the TPM, which means this won't work.

Then generate your SSH key inside your TPM:

    ssh-tpm-keygen

## Testing

    cat ~/.ssh/id_ecdsa.pub >>~/.ssh/authorized_keys
    ssh localhost

Transfer your `~/.ssh/id_ecdsa.pub` to https://github.com/settings/keys, and test it:

    ssh git@github.com

Nota bene: `ssh-add -L` will show _"The agent has no identities"_ until it's first used.

## Change Passphrase

    ssh-tpm-keygen -p

## Delete Key

You can't really delete the key in the TPM with `ssh-tpm-keygen`.

You can delete the files of the public key and the `*.tpm` _ "handle"_ in `~/.ssh/`.

You can override it with a new `ssh-tpm-keygen`.

## References

- `ssh-tpm-keygen --help`
- https://blog3.vorburger.ch/security/ssh-tpm/
- https://github.com/Foxboron/ssh-tpm-agent
- https://wiki.archlinux.org/title/Trusted_Platform_Module
