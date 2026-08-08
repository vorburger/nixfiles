let
  all = [
    # Host SSH public keys (use raw `ssh-ed25519 AAAAC3...` string from /etc/ssh/ssh_host_ed25519_key.pub or `ssh-keyscan -t ed25519 localhost`)
    # Note: `ragenix`/`agenix` system activation decrypts using /etc/ssh/ssh_host_ed25519_key directly via `ssh-ed25519` recipient format.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPobJWkfYiOfQ/dfIz6HYY9LooERxuxXBQGE+oBxQpPH" # ixo
    # "ssh-ed25519 AAAAC3..."; # titan TODO Replace with titan host key when generated

    # User Public Keys from hosts' TPMs; Useful because we want to run ragenix without sudo,
    # but host private keys cannot be read by regular users.
    # Note: age1tag1... type keys do NOT work here due to https://github.com/yaxitech/ragenix/issues/170,
    # we must use the age1tpm1... format obtained via "age-plugin-tpm --tpm-recipient -y ~/.config/age/identities".
    "age1tpm1qt0wrxgpsmxq6s29wydwrc4hedg3mpn6utl5e8adrnmau5f4udghvs66e5k" # ixo TPM

    # User "Forever Recovery Access" from YubiKeys, or last-ressort file or even paper backed.
    # Required because Host SSH and User TPM keys are by their very nature ultimately more "ephemeral".
    # TODO YubiKeys!!

    # Note: ecdsa-sha2-nistp256 public keys from ssh-tpm-agent are NOT supported here;
    # above are thus either age-plugin-tpm or age-plugin-yubikey keys, only.
  ];
in
{
  "encrypted/hello-secret.age".publicKeys = all;
}
