let
  # Host SSH public keys (derived via `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`)
  ixoHostKey = "age1gyt6zzy9ddnletlhaw90ec3e5wyc8h33e43mze0e4xtxjymek5zqn3henv"; # ixo ed25519 host key
  titanHostKey = "age1gyt6zzy9ddnletlhaw90ec3e5wyc8h33e43mze0e4xtxjymek5zqn3henv"; # titan host key placeholder

  # User / Admin Recovery Keys for "Forever Access" (YubiKey / Master key)
  # Replace/add your YubiKey age recipient (`age1yubikey1...`) or personal identity public key
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
