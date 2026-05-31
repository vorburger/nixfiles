{
  perSystem =
    { self', pkgs, ... }:
    {
      packages.vmb = pkgs.writeShellApplication {
        name = "vmb";
        runtimeInputs = [
          pkgs.nix-output-monitor
          pkgs.qemu
          pkgs.coreutils
          pkgs.findutils
          pkgs.openssh
        ];
        text = ''
          if [ $# -lt 2 ]; then
            echo "Usage: vmb <machine> <clean|keep>"
            exit 1
          fi

          MACH=$1
          MODE=$2

          DISK_IMAGE="$MACH-disk.raw"
          EFIVARS="$MACH-efivars.fd"

          if [ "$MODE" == "clean" ]; then
            rm -f "$DISK_IMAGE" "$EFIVARS"
          elif [ "$MODE" == "keep" ]; then
            true
          else
            echo "Invalid mode: $MODE (must be 'clean' or 'keep')"
            exit 1
          fi

          # Prepare efivars.fd if it does not exist
          if [ ! -f "$EFIVARS" ]; then
            echo "Copying UEFI variables store template for $MACH..."
            cp "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd" "$EFIVARS"
            chmod +w "$EFIVARS"
          fi

          # Build diskoImagesScript and run it if the disk image is missing
          if [ ! -f "$DISK_IMAGE" ]; then
            echo "Building disko image generation script for $MACH..."
            nom build .#nixosConfigurations."$MACH".config.system.build.diskoImagesScript -o tmp-disko-script

            echo "Generating disk image for $MACH..."
            TEMP_PASS=$(mktemp)
            echo -n "x" > "$TEMP_PASS"

            ./tmp-disko-script --pre-format-files "$TEMP_PASS" /tmp/luks.secret

            rm -f "$TEMP_PASS" tmp-disko-script

            # Find the newly generated .raw image (e.g. main.raw or my-disk.raw) and rename it
            if [ -f main.raw ]; then
              mv main.raw "$DISK_IMAGE"
            elif [ -f my-disk.raw ]; then
              mv my-disk.raw "$DISK_IMAGE"
            else
              found_raw=$(find . -maxdepth 1 -name "*.raw" ! -name "$DISK_IMAGE" -print -quit)
              if [ -n "$found_raw" ]; then
                mv "$found_raw" "$DISK_IMAGE"
              else
                echo "Error: No generated disk image found."
                exit 1
              fi
            fi
          fi

          echo "Booting $MACH VM from $DISK_IMAGE..."
          echo "NOTE: To unlock the encrypted home partition, enter 'x' at the boot prompt in the QEMU window."

          QEMU_KVM_OPTS=""
          if [ -w /dev/kvm ]; then
            QEMU_KVM_OPTS="-enable-kvm -cpu host"
          else
            echo "Warning: /dev/kvm is not writable. Running without KVM acceleration (this will be slow)."
            QEMU_KVM_OPTS="-cpu max"
          fi

          # shellcheck disable=SC2086
          qemu-system-x86_64 \
            $QEMU_KVM_OPTS \
            -m 2G \
            -smp 2 \
            -drive if=pflash,format=raw,unit=0,readonly=on,file="${pkgs.OVMF.fd}/FV/OVMF_CODE.fd" \
            -drive if=pflash,format=raw,unit=1,file="$EFIVARS" \
            -drive file="$DISK_IMAGE",if=virtio,format=raw \
            -net nic,model=virtio -net user,hostfwd=tcp::2222-:22 \
            -vga virtio \
            -display default,show-cursor=on &

          until ssh -A -F /dev/null -o ConnectTimeout=7 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" vorburger@127.0.0.1 -p 2222; do
            sleep 1
          done
        '';
      };

      checks.vmb = self'.packages.vmb;

      devshells.default = {
        commands = [
          {
            name = "vmb";
            package = self'.packages.vmb;
            help = "Build and boot a fully partitioned/encrypted NixOS VM from Disko image";
          }
        ];
      };
    };
}
