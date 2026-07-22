# SMART

On any new disks, whether brand new fresh from the factory or second hand, to get their controller
to find bad blocks and record [SMART](https://en.wikipedia.org/wiki/Self-Monitoring,_Analysis_and_Reporting_Technology),
do this, in this order:

1. Run a SMART Short Self-Test (~2') and a Conveyance Self-Test (5'),
   using GNOME Disks, [GSmartControl](#gsmartcontrol), or `sudo smartctl -t short /dev/sdX`
   and `sudo smartctl -t conveyance /dev/sdX`.

1. Run [`badblocks`](#badblocks) (N hours)

1. Run a SMART Long/Extended Self-Test (~12h); via UI, or `sudo smartctl -t long /dev/sdX`

1. Verify results, via UI, or `sudo smartctl -a /dev/sdX`, and watch out for:
   - `Reallocated_Sector_Ct` should be 0
   - `Current_Pending_Sector` must be 0
   - `Offline_Uncorrectable` must be 0

Running tests in this specific order should catch all damaged sectors etc.

It is recommended to run such extended disk stress tests by connecting the drive directly to
an internal SATA port instead of in an external enclosure via USB-to-SATA adapter.

## `badblocks`

Use the following **destructive** (!) command: (Where `-t` reduces the default
4 passes to 1, and `-c` increases the buffer from the tiny default (64 blocks) to test 65,536 blocks
at a time; this uses ~256 MB of RAM and significantly improves sequential I/O throughput.)

    sudo badblocks -wsv -t 0xaa -c 65536 /dev/sdX

In case this produces the following error on large (e.g. 8 TB) HDDs:

    badblocks: Value too large for defined data type invalid end block (7814026584): must be 32-bit value

then add `-b 4096` to increase the block size:

    time sudo badblocks -wsv -t 0xaa -c 65536 -b 4096 /dev/sdX

On a 8 TB HDD this will take about a day (?).

See e.g. the [Arch Linux Wiki for more background about `badblocks`](https://wiki.archlinux.org/title/Badblocks).

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
