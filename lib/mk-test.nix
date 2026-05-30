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
            imports = [
              module
              {
                # Workaround to avoid evaluation warning about root password options in VM tests
                users.users.root.initialHashedPassword = pkgs.lib.mkForce null;
              }
            ];
            nixpkgs.pkgs = lib.mkForce pkgs;
          };
          node.specialArgs = { inherit inputs self; };
          testScript =
            let
              bootCheck = ''
                machine.wait_for_unit("multi-user.target")
                machine.succeed("systemctl status --no-pager")
                # Ensure no systemd units have failed (ignoring register-nix-paths.service which is expected to fail in VM tests of installer profiles)
                machine.fail("systemctl --failed --no-legend | grep -v 'register-nix-paths.service' | grep -q .")
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
