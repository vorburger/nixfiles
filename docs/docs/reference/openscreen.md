# OpenScreen

[OpenScreen](https://getopenscreen.com/) is an open-source desktop screen recorder and video editor with built-in cursor telemetry, auto-zoom, local Whisper captions, and GPU compositing.

## Host Availability

OpenScreen is defined in `modules/tools/openscreen.nix` and enabled exclusively on the workstation host `titan` (`modules/hosts/titan.nix`):

```nix
programs.openscreen.enable = true;
```

It is disabled by default across all other hosts in `modules/hosts/_common.nix`.

## GPU Acceleration on Linux

### The Encoder Ladder

OpenScreen's Linux pipeline uses an automatic capability ladder for recording and MP4 export:

1. **VAAPI** (`h264_vaapi`): Hardware acceleration via VA-API.
2. **Vulkan** (`h264_vulkan`): Hardware acceleration via Vulkan video encode queues.
3. **Software** (`libopenh264`): CPU software encoding fallback.

### Titan (AMD GPU) vs Laptop (ixo without discrete GPU)

- **On `titan`**:
  Titan is equipped with an AMD Radeon GPU running Mesa drivers with `hardware.graphics.enable = true;`. The driver exposes VA-API hardware encoding (`radeonsi_drv_video.so`), and user `vorburger` is a member of the `render` group with access to `/dev/dri/renderD128`. OpenScreen automatically selects `h264_vaapi` for both real-time capture and MP4 export.
- **On a host without a GPU (e.g. `ixo`)**:
  OpenScreen dynamically probes encoder capabilities at launch. If no hardware encoder is found or initialisation fails, it transparently falls back to `libopenh264` (software encoding) without crashing or requiring distinct host configuration.
- **Overriding the Encoder**:
  To force a specific backend or verify selection:
  ```bash
  OPENSCREEN_LINUX_ENCODER=vaapi openscreen
  # or force software encoding:
  OPENSCREEN_LINUX_ENCODER=software openscreen
  ```

## Mouse Click Telemetry & Security

### Why Click Capture Needs Special Permissions on Wayland

Wayland intentionally isolates input events between windows for security. The Wayland ScreenCast portal provides cursor _position_, but does not stream button presses. To draw click animations and ripple effects, OpenScreen reads left mouse button presses (`BTN_LEFT`) from the Linux kernel evdev interface (`/dev/input/event*`).

### The Security Hazard of the `input` Group

Upstream documentation suggests adding the user to the `input` group:

```bash
sudo usermod -aG input $USER
```

Adding your user to the `input` group grants **every** process running under your user account (browsers, shell scripts, third-party dependencies, IDE extensions) permission to read every device node in `/dev/input/`, including all keyboards. This introduces a persistent keylogger vulnerability.

### Threat Profile Comparison

| Capability                    | Default Wayland | With Mouse udev `uaccess` |              With Scoped setgid Binary               |  With `sudo usermod -aG input`  |
| :---------------------------- | :-------------: | :-----------------------: | :--------------------------------------------------: | :-----------------------------: |
| **Keystrokes / Passwords**    |   🔒 Blocked    |      🔒 **Blocked**       | ⚠️ Exposes attack surface (helper has group `input`) | 🚨 **Exposed to all user apps** |
| **Global Mouse Clicks**       |   🔒 Blocked    | ⚠️ Readable by user apps  |          🔒 Blocked (only helper reads it)           |    ⚠️ Readable by user apps     |
| **Relative Mouse Motion**     |   🔒 Blocked    | ⚠️ Readable by user apps  |          🔒 Blocked (only helper reads it)           |    ⚠️ Readable by user apps     |
| **Synthetic Click Injection** |   🔒 Blocked    |      🔒 **Blocked**       |                      🔒 Blocked                      |           🔒 Blocked            |
| **Device Grab / Freeze**      |   🔒 Blocked    |  ⚠️ Possible via `ioctl`  |                      🔒 Blocked                      |     ⚠️ Possible via `ioctl`     |

### Architectural Decision: udev vs. setgid Wrapper

When securing click capture, two technical routes exist:

1. **Targeted udev `uaccess` (Recommended)**: Dynamically grant the active desktop seat user access strictly to mouse character devices (`ENV{ID_INPUT_KEYBOARD}!="1"`).
2. **Scoped setgid Wrapper**: Create a setgid wrapper binary (`owner = "root"`, `group = "input"`, mode `2750`) so only the helper binary acquires group `input`.

#### Why the udev Route is Recommended

We recommend and implement the **targeted udev approach** as a closed architectural choice:

- **Zero Privileged Binaries**: The setgid approach introduces a setgid binary on disk. Even though setgid does not elevate UID to root, it grants the helper executable permission to read **all** `input` devices—including physical keyboards. If that helper binary ever has a memory safety bug or vulnerability, it could be leveraged to snoop on keyboards.
- **Kernel-Level Keyboard Exclusion**: The udev approach enforces hardware device isolation at the kernel level (`ENV{ID_INPUT_KEYBOARD}!="1"`). Even if userspace is compromised, the kernel refuses to open keyboard event character devices.
- **Native Desktop Integration**: It leverages standard `systemd-logind` seat management, matching how cameras, audio devices, and GPUs are exposed to desktop sessions.

### Enabling Click Capture Safely

OpenScreen works completely out of the box without click capture (default). If click animations are desired, enable the safe udev rule via:

```nix
programs.openscreen.captureMouseClicks = true;
```

This deploys:

```udev
KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", ENV{ID_INPUT_KEYBOARD}!="1", TAG+="uaccess"
```

Systemd's `logind` assigns dynamic POSIX ACLs (`setfacl`) on mouse devices for the active desktop seat session while leaving keyboards strictly protected.

## Links

- Conceptual Security Analysis: [Evdev Mouse Click Telemetry Security on Wayland](https://wiki.enola.dev/computer/linux/security/evdev-click-telemetry-security)
- [OpenScreen Official Website](https://getopenscreen.com/)
- [OpenScreen Linux Installation & Platform Guide](https://getopenscreen.com/docs/installation/#linux)
- [OpenScreen GitHub Repository](https://github.com/getopenscreen/openscreen)
