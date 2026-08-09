# Machine-readable identity handles and host public keys.
# Identity handles (identities) are used to populate ~/.config/age/identities for decryption.
# Host SSH keys (hostKeys) are used by NixOS activation to decrypt secrets via /etc/ssh/ssh_host_ed25519_key.
{
  # User hardware / plugin identities (identity handles)
  identities = {
    # Portable YubiKey
    portable-yubikey = ''
      #       Serial: 9599730, Slot: 1
      #         Name: age identity aedaf77b
      #      Created: Sat, 08 Aug 2026 22:09:57 +0000
      #   PIN policy: Once   (A PIN is required once per session, if set)
      # Touch policy: Always (A physical touch is required for every decryption)
      #    Recipient: age1yubikey1qd5rn4s8d04pjkhqe4xq8nspc883gm7jnnk3pucsr33yg6eq00v9uq5tsas
      AGE-PLUGIN-YUBIKEY-17FAFYQYZ4MD0W7CZP5JUV
    '';

    # ixo TPM identity
    ixo-tpm = ''
      AGE-PLUGIN-TPM-1QGQSQKQQYVQQKQQZQPEQQQQQZQQPJQQTQQPSQYQQYR0WRXGPSMXQ6S29WYDWRC4HEDG3MPN6UTL5E8ADRNMAU5F4UDGHVQPQAA8MU4CHL808V0GE2PTKJTUT7XP89KSNYTQMXCYKRWPFX5QENE5QQLSQYZPWUTA9WVV2HAYRL3DLA8DM2CCCPJ6R8F985D7G32QQC559ULZ6QQQS35CFYSFKXG94AWUK56HRLMZMTC7YE92RH9FZEX4UU7CFA85ZYQZL0U5QKAUG94CQ7AX9PWLQHV6WLW8XECL2YRNS5K5GE2JKFADDX43TS8F4P4ZJ7N7EE0750TW6DAC4D5AJ0LUSV232XACNQQ3QQZCKDV46YPLYZ6NM2NM2XG4NH0KH6A03YEUMF5LDM7YECN2NAV633CX8SFRU
    '';
  };

  # Host SSH Public Keys (OpenSSH format)
  hostKeys = {
    ixo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPobJWkfYiOfQ/dfIz6HYY9LooERxuxXBQGE+oBxQpPH";
    # titan = "ssh-ed25519 AAAAC3..."; # TODO Add titan host SSH key when generated
  };
}
