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

### The Security Concern with `sudo usermod -aG input $USER`

Upstream documentation suggests adding the user to the `input` group:

```bash
sudo usermod -aG input $USER
```

Adding your user to the `input` group grants **every** process running under your user account (browsers, shell scripts, third-party libraries, IDE extensions) permission to read every device node in `/dev/input/`, including all keyboards. This creates a potential keylogger vulnerability.

### Secure Alternatives

1. **Standard Recording without Click Capture (Default)**:
   OpenScreen works completely out of the box without the `input` group. Video, system audio, microphone, webcam, and cursor movements are captured normally. Every cursor sample is simply recorded as movement rather than distinguishing clicks.
2. **Mouse-Only udev Rule (`captureMouseClicks`)**:
   `modules/tools/openscreen.nix` provides an option:
   ```nix
   programs.openscreen.captureMouseClicks = true;
   ```
   This deploys a udev rule:
   ```udev
   KERNEL=="event*", SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", ENV{ID_INPUT_KEYBOARD}!="1", TAG+="uaccess"
   ```
   Systemd's logind automatically applies POSIX ACLs (`setfacl`) on mouse devices for the active desktop seat user. Keyboards are explicitly excluded (`ENV{ID_INPUT_KEYBOARD}!="1"`), so no keyboard access is ever granted to unprivileged user processes, and the user does not need to join the `input` group.

## Links

- [OpenScreen Official Website](https://getopenscreen.com/)
- [OpenScreen Linux Installation & Platform Guide](https://getopenscreen.com/docs/installation/#linux)
- [OpenScreen GitHub Repository](https://github.com/getopenscreen/openscreen)
