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
