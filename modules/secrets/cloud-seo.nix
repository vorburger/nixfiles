let
  inherit (import ../../lib/mk-secret.nix) mkSecret;
in
mkSecret {
  name = "cloud-seo";
  owner = "vorburger";
  mode = "0400";

  # Encrypt only for titan, ixo, and your personal admin/YubiKey/TPM keys
  # (per Principle 6 "Forever Access" in docs/docs/reference/secrets.md)
  publicKeys = recipients: [
    recipients.titan
    recipients.ixo
    recipients.portable-yubikey-9599730
    recipients.titan-yubikey-10300902
    recipients.ixo-tpm
  ];
}
