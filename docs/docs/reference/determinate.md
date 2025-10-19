# Determinate Systems Nix

## Install

https://docs.determinate.systems explains how to install their Nix distribution on:

- non-NixOS Linux systems, like Fedora, Ubuntu, Debian, Arch Linux, etc.
- Windows Subsystem for Linux (WSL)
- macOS

This distribution is recommended on Fedora over the [upstream `nix`](nix-cli.md).

It is usually behind the latest upstream Nix version, but typically only slightly.

## Update

```sh
$ nix --version
nix (Determinate Nix 3.4.2) 2.28.3

$ sudo determinate-nixd upgrade
Upgrading Determinate Nixd...
Upgrading Determinate Nix...

$ nix --version
nix (Determinate Nix 3.11.3) 2.31.2
```

## Daemon

```sh
$ systemctl status nix-daemon
● nix-daemon.service - Nix Daemon, with Determinate Nix superpowers.
     Loaded: loaded (/etc/systemd/system/nix-daemon.service; disabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf, 50-keep-warm.conf
     Active: active (running) since Sun 2025-10-19 13:53:41 CEST; 1h 28min ago
 Invocation: 59028b3afdd644d598f1ae2a93c4748d
TriggeredBy: ● determinate-nixd.socket
             ● nix-daemon.socket
       Docs: man:nix-daemon
             https://determinate.systems
   Main PID: 701408 (determinate-nix)
      Tasks: 26 (limit: 1048576)
     Memory: 38.5M (peak: 66M)
        CPU: 4.889s
     CGroup: /system.slice/nix-daemon.service
             ├─701408 determinate-nixd daemon
             └─701422 /nix/var/nix/profiles/default/bin/nix-daemon --option json-log-path /nix/var/determinate/determinate-nixd-logger.socket
```

Use `systemctl restart nix-daemon` to restart the daemon after changing `/etc/nix/nix.conf` or `~/.config/nix/nix.conf`.
