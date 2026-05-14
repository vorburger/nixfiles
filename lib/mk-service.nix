# This is an internal helper to reduce boilerplate in ../services/.
# It is imported by each service module.
{
  mkService =
    {
      name,
      description,
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
      resolvedExtraOptions = if builtins.isFunction extraOptions then extraOptions args else extraOptions;
    in
    {
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
