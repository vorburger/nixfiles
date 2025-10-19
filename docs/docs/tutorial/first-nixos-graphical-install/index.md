# First NixOS Graphical Install

## Prerequisites

- You do NOT need the `nix` CLI (here).
- Have a VM manager available, e.g. [VirtualBox](https://www.virtualbox.org/wiki/Downloads), [GNOME Boxes](https://wiki.gnome.org/Apps/Boxes), etc.
- Download the latest `nixos-graphical-*-x86_64-linux.iso` from https://nixos.org/download.

## Installation

1. Boot the ISO in a new VM (using BIOS instead of UEFI).
1. The _NixOs Installer_ should have started automatically - step through it.
1. As we'll initial focus on a minimal headless server installation chose _No Desktop_ (for now).
1. At the end, shut-down the VM, remove the installation ISO image, and restart the VM.

You now have your very first NixOS-based (VM) machine!

PS: The screen & font may be tiny; we'll fix that later.

## Nix files

The result of the graphical configuration from the previous step is stored in `/etc/nixos/configuration.nix` (and its `hardware-configuration.nix`).

You can edit that file to further customize your NixOS installation.

## SSH

Let's enable SSH access! Edit `/etc/nixos/configuration.nix` and uncomment the following line:

```nix
services.openssh.enable = true;
```

Run `sudo nixos-rebuild switch` to apply the changes.

Test that SSH is working by connecting locally from the VM to itself:

```sh
ssh localhost
```

To connect from the host to the VM, find out the VM's IP address
(e.g., using `ip a` on the VM; for GNOME Boxes, it may be `192.168.122.x`),
and connect to that IP address from your host machine:

```sh
ssh -At <vm-ip-address>
```

## Packages

Let's install some packages, like `git` and perhaps the `fish` shell - and any others you may want.
Edit `/etc/nixos/configuration.nix` and add the following lines inside the top-level `{ config, pkgs, ... }:` block:

```nix
environment.systemPackages = with pkgs; [
  fish
  git
];
```

Note that NixOS has `environment.systemPackages` as well as a `packages` in the `users.users.<your-username>` section.
We're using `environment.systemPackages` here to install packages system-wide for now, and will revisit user-specific packages later.

After editing, run `sudo nixos-rebuild switch` again; you now have `git` and `fish` installed.

## Git

It's a good idea to keep your NixOS configuration files in a Git repository. Create your own `nixfiles` Git repository now - similar to this! Then do something like:

```sh
mkdir modules/hosts/vm1
scp "192.168.122.72:/etc/nixos/*" modules/hosts/vm1/
```
