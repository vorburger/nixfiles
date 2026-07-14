# SMART

## `badblocks`

TODO

- https://wiki.archlinux.org/title/Badblocks

## GSmartControl

Run _GSmartControl_ via the GNOME Apps launcher, or if that doesn't start, then via the terminal like this:

    sudo WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR gsmartcontrol

GNOME Disks (`gnome-disks`) also shows some of this - but GSmartControl is much more comprehensive.
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

TODO

## scrutiny WebUI for `smartd` S.M.A.R.T monitoring

TODO https://github.com/AnalogJ/scrutiny
