{
  inputs,
  self,
  ...
}:
{
  mkTest = name: module: testScript: {
    perSystem =
      { pkgs, ... }:
      {
        checks.${name} = pkgs.testers.runNixOSTest {
          inherit name;
          nodes.machine = {
            imports = [ module ];
          };
          node.specialArgs = { inherit inputs self; };
          testScript =
            if testScript != null then
              testScript
            else
              ''
                machine.wait_for_unit("multi-user.target")
              '';
        };
      };
  };
}
