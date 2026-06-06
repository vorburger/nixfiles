{
  inputs,
  self,
  lib,

}:
{
  mkTest =
    {
      name,
      module,
      testScript,
      nixpkgs ? inputs.nixpkgs,
    }:
    let
      system = "x86_64-linux"; # default system, can be overridden if needed
    in
    {
      perSystem =
        {
          pkgs ? nixpkgs.legacyPackages.${system},
          ...
        }:
        let
          hostName = lib.removeSuffix "-boot" name;
          forwardPorts =
            self.nixosConfigurations.${hostName}.config.virtualisation.vmVariant.virtualisation.forwardPorts;
          hasSshForward = lib.any (fp: fp.host.port == 2222 && fp.guest.port == 22) forwardPorts;
        in
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
            node.specialArgs = {
              inherit inputs self;
              vmTest = true;
            };
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

          checks."${hostName}-vm-port-forward" =
            if hostName == "installer" || hasSshForward then
              pkgs.runCommand "${hostName}-vm-port-forward-check" { } "touch $out"
            else
              throw "Host '${hostName}' is missing VM port 2222 -> 22 forwarding in its virtualisation.vmVariant config!";

        };
    };
}
