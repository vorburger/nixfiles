{ inputs, self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks.test1-boot = pkgs.testers.runNixOSTest {
        name = "test1-boot";
        nodes.machine = {
          imports = [ self.nixosModules.test1 ];
        };
        node.specialArgs = { inherit inputs; };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
        '';
      };
    };
}
