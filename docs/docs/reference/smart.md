# SMART

## `badblocks`

Run `badblocks` on new disks to get their controller to find bad blocks and record
[SMART](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology)
statistics, using the following **destructive** (!) command:

    sudo badblocks -wsv /dev/sdc

In case this produces the following error on large (e.g. 8 TB) HDDs:

    badblocks: Value too large for defined data type invalid end block (7814026584): must be 32-bit value

then add `-b 4096` to increase the block size:

    sudo badblocks -wsv -b 4096 /dev/sdc

On a 8 TB HDD this will take about 12h. See e.g. the [Arch Linux Wiki for more background about `badblocks`](https://wiki.archlinux.org/title/Badblocks).

## GSmartControl

Run _GSmartControl_ via the GNOME Apps launcher, or if that doesn't start, then via the terminal like this:

    sudo WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR gsmartcontrol

PS: GNOME Disks (`gnome-disks`) also shows some of this - but GSmartControl is more comprehensive.
(GNOME Disks may also have _"SMART Data & Self-Tests"_ greyed out when a SATA HDD is connected over
some USB adapters, whereas GSmartControl works even then.)

## `smartctl`

https://www.smartmontools.org:

    $ sudo smartctl --scan-open
    /dev/sda -d sat # /dev/sda, ATA device
    /dev/sdb -d sat # /dev/sdb, ATA device
    /dev/nvme0 -d nvme # /dev/nvme0, NVMe device
    /dev/nvme1 -d nvme # /dev/nvme1, NVMe device

and then:

    sudo smartctl -x /dev/sda

or:

    sudo smartctl --scan-open | awk '{print $1, $2, $3}' | xargs -L 1 sudo smartctl -x

## `smartd`

TODO [`services.smartd.*`](https://search.nixos.org/options?channel=unstable&query=smartd&type=options)

## scrutiny WebUI for `smartd` S.M.A.R.T monitoring

TODO https://github.com/AnalogJ/scrutiny
