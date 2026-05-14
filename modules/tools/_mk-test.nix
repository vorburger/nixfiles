{ inputs, self }:
name: module: {
  perSystem =
    { pkgs, ... }:
    {
      checks.${name} = pkgs.testers.runNixOSTest {
        inherit name;
        nodes.machine = module;
        node.specialArgs = { inherit inputs self; };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
        '';
      };
    };
}
