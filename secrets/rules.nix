let
  lib = import <nixpkgs/lib>;
  keys = (import ./recipients.nix).recipients;

  # Recursively find all .nix files in ../modules
  findNixFiles =
    dir:
    let
      entries = builtins.readDir dir;
      processEntry =
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "directory" then
          findNixFiles path
        else if type == "regular" && lib.hasSuffix ".nix" name then
          [ path ]
        else
          [ ];
    in
    builtins.concatLists (builtins.attrValues (builtins.mapAttrs processEntry entries));

  # Import a module file safely
  importModule =
    path:
    let
      imported = import path;
    in
    if builtins.isFunction imported then
      let
        args = builtins.functionArgs imported;
        provided = {
          inputs = { };
          inherit lib;
          pkgs = { };
          self = { };
          config = { };
        };
        required = lib.filterAttrs (_n: v: !v) args;
        missing = lib.filterAttrs (n: _v: !(builtins.hasAttr n provided)) required;
      in
      if missing == { } then
        let
          res = builtins.tryEval (imported provided);
        in
        if res.success && builtins.isAttrs res.value then res.value else { }
      else
        { }
    else if builtins.isAttrs imported then
      imported
    else
      { };

  allModules = map importModule (findNixFiles ../modules);

  # Collect all flake.secretRules defined across modules
  collectRules =
    acc: mod:
    let
      rules = mod.flake.secretRules or { };
      evaluated = if builtins.isFunction rules then rules keys else rules;
    in
    acc // evaluated;
in
builtins.foldl' collectRules { } allModules
