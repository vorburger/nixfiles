# This is an internal helper to reduce boilerplate in ../services/.
# It is imported by each service module.
{
  mkService =
    {
      name,
      description,
      imports ? (_: [ ]),
      extraOptions ? (_: { }),
      content,
    }:
    {
      config,
      lib,
      pkgs,
      ...
    }@args:
    let
      cfg = config.services.${name};
      resolvedImports = if builtins.isFunction imports then imports args else imports;
      resolvedExtraOptions = if builtins.isFunction extraOptions then extraOptions args else extraOptions;
    in
    {
      imports = resolvedImports;

      options.services.${name} = {
        enable = lib.mkEnableOption description;
      }
      // resolvedExtraOptions;

      config = lib.mkIf cfg.enable (
        if builtins.isFunction content then
          content (
            args
            // {
              inherit cfg pkgs;
              selfCfg = cfg;
            }
          )
        else
          content
      );
    };
}
