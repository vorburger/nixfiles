# Power Management

This document explains the design and usage of the automated power management system implemented for laptops in this NixOS configuration (enabled via `services.power.enable`).

## Overview

The power management configuration integrates two complementary tools to optimize battery life and system performance on NixOS laptops like `ixo`:

1. **`power-profiles-daemon` (High-level CPU performance profiles):** Coordinates high-level power states (`performance`, `balanced`, `power-saver`) directly with modern CPU drivers (e.g. `intel_pstate` or AMD equivalents) and BIOS ACPI platform profiles.
2. **`powertop` (Low-level hardware-level optimization):** Diagnoses device-level power draw and auto-tunes hardware settings (such as USB autosuspend, SATA link power, PCIe states) to maximize power savings.

---

## Automatic Profile Switcher

While GNOME provides manual sliders to switch power profiles, it does not dynamically adjust them based on battery thresholds. We implement a custom switcher to automate this:

| Power State         | Battery Percentage | Active Power Profile |
| ------------------- | ------------------ | -------------------- |
| **Plugged In (AC)** | Any                | `performance`        |
| **Battery**         | ⪫ 40%              | `balanced`           |
| **Battery**         | < 40%              | `power-saver`        |

### Architecture

The switcher consists of:

- **A shell script:** Queries the battery capacity and AC status via `/sys/class/power_supply` and calls `powerprofilesctl set`.
- **A udev rule:** Triggers the switcher service whenever the power supply status changes (e.g., plugging or unplugging the charger).
- **A systemd timer fallback:** Runs the switcher service every 5 minutes in case a udev event is missed or battery capacity changes incrementally without triggering a udev event.

---

## Diagnostics & Verification

### Checking Power Profiles

To see the active power profile, run:

```bash
powerprofilesctl get
```

To see all available profiles:

```bash
powerprofilesctl list
```

### Checking Low-Level Tuning (`powertop`)

To run `powertop` interactively and check active power consumption (in Watts) or inspect the status of hardware tunables, run:

```bash
sudo powertop
```

### Checking Switcher Status

You can view the systemd logs for the switcher service to verify that it is triggering correctly:

```bash
sudo journalctl -u power-profile-switcher.service
```

---

## Suspend Power Optimization (s2idle / Modern Standby)

Modern Intel processors (such as the Meteor Lake CPU on `ixo`) do not support traditional S3 "deep" sleep. Instead, they use `s2idle` (Suspend-to-Idle / Modern Standby). This can lead to noticeable battery drain (e.g., 10% over several hours or overnight) if peripherals keep waking the CPU or preventing the SoC from entering its deepest package power-saving states (like C10).

To minimize suspend drain, `services.power.enable` installs a systemd service (`disable-wakeup-triggers.service`) that automatically disables sleep wakeup triggers for USB controllers (`XHCI`) and Thunderbolt controllers (`TXHC`) on system boot.

### Diagnostics & Troubleshooting

1. **Check active sleep states:**

   ```bash
   cat /sys/power/mem_sleep
   # Output should show `[s2idle]`
   ```

2. **Check enabled wakeup devices:**

   ```bash
   cat /proc/acpi/wakeup
   # Devices with `*enabled` status can wake the system or keep it from entering deep sleep.
   ```

3. **Check the status of the wakeup-trigger disabler:**
   ```bash
   systemctl status disable-wakeup-triggers.service
   ```
