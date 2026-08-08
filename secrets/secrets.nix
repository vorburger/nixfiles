let
  # Host SSH public keys (use raw `ssh-ed25519 AAAAC3...` string from /etc/ssh/ssh_host_ed25519_key.pub or `ssh-keyscan -t ed25519 localhost`)
  # Note: `ragenix`/`agenix` system activation decrypts using /etc/ssh/ssh_host_ed25519_key directly via `ssh-ed25519` recipient format.
  ixoHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPobJWkfYiOfQ/dfIz6HYY9LooERxuxXBQGE+oBxQpPH";
  titanHostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPobJWkfYiOfQ/dfIz6HYY9LooERxuxXBQGE+oBxQpPH";

  # User / Admin Recovery Keys for "Forever Access" (YubiKey / Master key)
  userMasterKey = "age1q57l6ph65sfd3x7ltahjumns8uamtsyz6eg3ek79kass4phkrf8s82u0px";

  allHosts = [
    ixoHostKey
    titanHostKey
    userMasterKey
  ];
in
{
  "hello-secret.age".publicKeys = allHosts;
}
