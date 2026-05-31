{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        runtimeInputs = [
          pkgs.nh
          pkgs.nix-output-monitor
          pkgs.openssh
        ];
        text = ''
          if [ $# -lt 2 ]; then
            echo "Usage: vm <machine> <clean|keep>"
            exit 1
          fi

          MACH=$1
          MODE=$2

          if [ "$MODE" == "clean" ]; then
            rm -f "$MACH.qcow2"
          elif [ "$MODE" == "keep" ]; then
            true
          else
            echo "Invalid mode: $MODE (must be 'clean' or 'keep')"
            exit 1
          fi

          nh os build-vm .#"$MACH" -o result

          # shellcheck disable=SC2016
          result/bin/run-"$MACH"-vm &

          until ssh -A -F /dev/null -o ConnectTimeout=7 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" vorburger@127.0.0.1 -p 2222; do
            sleep 1
          done
        '';
      };

      checks.vm = self'.packages.vm;

      devshells.default = {
        commands = [
          {
            name = "vm";
            package = self'.packages.vm;
            help = "Build and run a NixOS VM";
          }
        ];
      };
    };
}
