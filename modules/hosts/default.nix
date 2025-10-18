_:
let
  vm = import ./test1-vm.nix;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.test1-vm = pkgs.runCommand "test1-vm" { } ''
        mkdir -p $out/bin
        ln -s ${vm.config.system.build.vm}/bin/run-test1-vm-vm $out/bin/run-vm
      '';
    };
}
