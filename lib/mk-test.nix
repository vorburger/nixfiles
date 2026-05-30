{
  inputs,
  self,
  lib,
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
            nixpkgs.pkgs = lib.mkForce pkgs;
          };
          node.specialArgs = { inherit inputs self; };
          testScript =
            let
              bootCheck = ''
                machine.wait_for_unit("multi-user.target")
                machine.succeed("systemctl status --no-pager")
              '';
            in
            if testScript != null then
              ''
                ${bootCheck}
                ${testScript}
              ''
            else
              bootCheck;
        };
      };
  };
}
