# Internal helper to reduce secret definition boilerplate.
# It automatically derives relative secret paths for NixOS modules and ragenix secretRules from the secret name.
{
  mkSecret =
    {
      name,
      moduleName ? name,
      file ? ../secrets/encrypted/${name}.age,
      mode ? "0400",
      owner ? "root",
      group ? "root",
      publicKeys ? (recipients: builtins.attrValues recipients),
    }:
    {
      flake.nixosModules.${moduleName} = {
        age.secrets.${name} = {
          inherit
            file
            mode
            owner
            group
            ;
        };
      };

      flake.secretRules = recipients: {
        "encrypted/${name}.age".publicKeys =
          if builtins.isFunction publicKeys then publicKeys recipients else publicKeys;
      };
    };
}
