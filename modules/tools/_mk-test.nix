{ inputs, self }:
name: module: {
  perSystem =
    { pkgs, ... }:
    {
      checks.${name} = pkgs.testers.runNixOSTest {
        inherit name;
        nodes.machine = {
          imports = [ module ];
        };
        node.specialArgs = { inherit inputs self; };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
        '';
      };
    };
}
