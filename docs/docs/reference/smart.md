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

On a 8 TB CMR HDD this will take about a day (~27h).

See e.g. the [Arch Linux Wiki for more background about `badblocks`](https://wiki.archlinux.org/title/Badblocks).

## GSmartControl

Run _GSmartControl_ via the GNOME Apps launcher, or if that doesn't start, then via the terminal like this:

    sudo WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR gsmartcontrol

PS: GNOME Disks (`gnome-disks`) also shows some of this - but GSmartControl is more comprehensive.
(GNOME Disks may also have _"SMART Data & Self-Tests"_ greyed out when a SATA HDD is connected over
some USB adapters, whereas GSmartControl works even then.)

### Run Extended Self-Test on unmounted disks

Drive firmware runs SMART self-tests in the background. However, the drive controller prioritizes host read/write I/O (from mounted filesystems, OS background tasks, or ZFS scrubs) over internal self-test operations. When host I/O occurs, the drive interrupts, delays, or aborts the self-test, causing it to take significantly longer or fail to complete cleanly.

Running tests on **unmounted** (or unformatted/idle) disks ensures the drive firmware executes the self-test continuously at maximum speed without I/O contention.

### `ETA: 0 sec`

GSmartControl calculates test ETA based on the remaining percentage reported by the drive firmware. The UI may show `ETA: 0 sec` while a test is still running for several reasons:

1. **10% Step Granularity in ATA Specification:** Per the [ATA/ATAPI Command Set - 3 (ACS-3)](https://www.t13.org/) specification (ACS-2 / ATA8-ACS section 7.52 _SMART READ DATA_, byte 363: _Self-test execution status_), drive firmware reports self-test progress in coarse 10% decrements (`90%`, `80%`, ..., `10%`, `0% remaining`). The status `0% remaining` (which GSmartControl displays as `ETA: 0 sec`) means **between 0% and 10%** of the scan remains.
   - On modern high-capacity HDDs (8 TB – 24 TB+), an Extended Self-Test takes **15 to 30+ hours**.
   - Because 10% of a 20-hour test is **2 full hours (120 minutes)**, `ETA: 0 sec` is shown during the entire final 2 hours of sector scanning!
2. **Firmware Log Flush & Internal Maintenance:** Once 100% of the sectors are scanned, the drive microcode must flush test results to non-volatile system tracks (reserved service area SMART logs) and transition the status byte from `0x24` (_in progress_) to `0x00` (_completed without error_).
3. **Host I/O Interruption:** Active host reads/writes force the drive to pause the background self-test.
4. **USB Bridge Limitations:** Some USB-to-SATA bridge chipsets do not pass real-time progress updates during background self-tests.

Recommended wait time:

- **Large HDDs (4 TB – 24 TB+):** Wait **up to 10% of total test duration** (typically **1 to 3 hours**) after `ETA: 0 sec` / `0% remaining` is first displayed.
- **Smaller Drives / SSDs:** Wait at least **15 to 30 minutes**.

#### Troubleshooting Steps

1. **Check Kernel logs for drive resets or timeouts:** `journalctl -k -g "(ata|sd|smart)"`
2. **Verify status via terminal:** Query the drive's self-test log directly:

   ```bash
   sudo smartctl -c /dev/sdX
   sudo smartctl -l selftest /dev/sdX
   ```

   If the top entry shows `Completed without error`, the test is finished. If it shows `Self-test routine in progress... 0% of test remaining`, the drive is still scanning the final sector range or writing logs.

3. **Unmount and restart if stuck:** If progress really remains stuck at `0 sec` for significantly longer than 10% of the total test duration (e.g. > 3–4 hours on an 8 TB drive), you could try to cancel the test (via UI, or `sudo smartctl -X /dev/sdX`), and restart it.

### Warning: `[hz] Warning: exit: Some SMART command to the disk failed, or there was a checksum error in a SMART data structure`

This warning in GSmartControl logs occurs when it queries SMART features or log pages that are not supported by the specific drive model or its USB bridge controller (SAT translation layer).

This might also happen when GSmartControl polls the drive for an update while the drive's controller is fully locked up processing an unreadable sector or busy scanning. The drive delays responding to the SMART status command, causing the tool to report a checksum or command timeout.

- **Is it concerning?** Usually **no**. It is benign if the overall SMART status reports `PASSED` / `HEALTH OK` and critical attributes (`Reallocated_Sector_Ct`, `Current_Pending_Sector`, `Offline_Uncorrectable`) are all `0`.
- **When to investigate:** If the warning is accompanied by SMART health failure alerts, failed self-test log entries, or non-zero reallocated/pending sector counts, check `sudo smartctl -a /dev/sdX` for details.

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
