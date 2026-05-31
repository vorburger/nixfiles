# ToDo

1. https://2026.nixcon.org ?

1. NUC should not have the workstation profile, but a (new) "headless" one, e.g. without Sound and most (or any at all?) things from workstation.nix;
   see also https://nixos.org/manual/nixos/stable/#sec-profile-headless

1. LUKS **with TPM** https://nixos.org/manual/nixos/stable/#sec-luks-file-systems

   ```nix
   boot.initrd.systemd.enable = true; # Required for modern systemd-cryptsetup
   security.tpm2.enable = true;

   $ sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
   ```

1. Try out the new `_learn-zfs.nix`layout on Vinea...

1. ZFS; first in Vinea's VM and/or BM, then on ThinkStation (BM) https://wiki.nixos.org/wiki/ZFS

1. Have both unstable and fixed nix pkgs - for different hosts; https://status.nixos.org Stable NixOS instead of -unstable for production machines hosts with ZFS

1. `users.mutableUsers` should be false

1. [Impermanence](https://www.youtube.com/watch?v=ZKBSWS7OOb4&t=6s) with [`preservation`](https://github.com/nix-community/preservation), see [vimjoyer](https://www.vimjoyer.com/vid89-impermanent)

1. Wireguard into NUC

1. ThinkStation as GNOME Workstation 0.1 (on external USB, to first backup ToNAS, the wipe SSD)

1. Use systemd instead of grub as bootloader on all hosts, for uniformity

1. Ixo powersaving: powerctl? tlp?
   https://wiki.archlinux.org/title/Powertop, and/or
   https://wiki.archlinux.org/title/TLP

1. https://wiki.nixos.org/wiki/Secret_Service, consider https://dewaldv.com/posts/2026-03-24-proton-pass-secret-service/ ?

1. Read https://clan.lol/docs/25.11/guides/vars/vars-overview, and transition from my `pass` to [`passage`](https://github.com/FiloSottile/passage); THEN use ~~`sopsnix` or~~ `agenix` for secrets management; best together with https://github.com/Foxboron/age-plugin-tpm ?

1. Backups ... https://www.borgbackup.org ? syncthing

1. https://syncthing.net server, for client on Android for Photos

1. Cloud VMs? `imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ]` ? See e.g. [this announcement](https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html).

1. Secure Boot!!
   - Not possible to still dual boot Fedora?
   - Does `ssh-tpm-agent` still work?!

1. https://nixos.org/manual/nixos/stable/#sec-upgrading-automatic

## Workstations & Laptops

1. Ixo solve <> key map problem (how?)

1. Configure GNOME Keyboard to "German (Switzerland)" instead of ch+de; this should also fix why locale-ch keyboard layout does not work in GNOME VM ... the Settings Keyboard does show ch-de, but the keys aren't mapped correctly. Perhaps this is more of a QEMU than a GNOME thing?

1. Configure GNOME Power Setttings to Preserve Battery Health

1. Disable the default folders created in home directories. And their bookmark shortcuts in the file chooser. What creates them? GNOME? I don't want a ~/Desktop/ nor a ~/Documents/ nor ~/Music/ nor ~/Pictures/ nor ~/Projects/ nor ~/Templates/ nor ~/Videos/. But ~/Downloads/ and ~/Public/ should be kept. If there is no config knob for this, perhaps just a session start script in dotfiles which rm them IFF they are empty?

1. Ctrl-R is broken on Console, but works in Kitty on GNOME

1. Login and go straight into TMUX

1. https://github.com/vorburger/password-store/pulls for `pass`

1. Ctrl-Backspace in Fish on Console (only; works over SSH)

1. Alt Left/Right in nano

1. Shift Up/Down, Alt Up/Down, Ctrl PgUp/PgDown
   https://gemini.google.com/app/394387d4e13b598c

1. True Colors!! Both on Console, and when logged in remotely over ssh in tmux

1. Try `services.howdy.enable = true; security.pam.services.sudo.howdyAuth = true;`

1. Home Manager `services.syshud` (new, 2026-04-12; update) A simple system status indicator for Wayland compositors.

## Nix Common #later

1. Nix lang tutorial

1. Check `systemctl status` and show failures

1. `tmux` should remember open tabs over restart

1. Compare `pstree` on Nix Console and Fedora in GNOME

1. Cache on CI

1. WiFi setup baked in into installer, as it now is for ixo

1. Try https://github.com/Foxboron/ssh-tpm-agent/issues/109

1. Try https://yazi-rs.github.io

1. Try https://github.com/microvm-nix/microvm.nix?
   See https://michael.stapelberg.ch/posts/2026-02-01-coding-agent-microvm-nix/.

1. `nix-store --optimise` how much does it save? How long does it run? Create a systemd timer...

1. https://wiki.archlinux.org/title/Intel_NUC#LEDs for activity?

## Upstream

1. Upstream configurations of any services et al. which ideally shouldn't be here at all

1. [ssh-tpm-agent: keyutils](https://github.com/NixOS/nixpkgs/pull/505874)

1. How to isolate? Merely building `ssh-tpm-agent` locally from `nixpkgs` (but probably even standalone) breaks `ssh` on OS.

1. [Add a system service for ssh-tpm-agent](https://github.com/NixOS/nixpkgs/issues/353096)

## Machines

1. `nixos-rebuild ... --specialisation XYZ` for different use cases?

1. Clan!
   - https://docs.clan.lol/guides/nixpkgs-flake-input/
   - https://docs.clan.lol/guides/flake-parts/
   - https://docs.clan.lol/guides/nixos-rebuild/

1. Replace `hostfwd=tcp::2222-:22` with proper bridged networking to get real IP address?

1. Replace `StrictHostKeyChecking=no` with fixed hostkey from secret vault

1. Try https://nixcademy.com/posts/auto-growing-nixos-appliance-images-with-systemd-repart/

## Tools

1. Formatters are a mess; `tools/git-hooks.nix` _pre-commit_ and `fmt.nix` for `nix fmt` don't share .treefmt.toml config?

1. Run `nix flake check` in pre-commit hook

1. Replace [`devshells`](https://github.com/numtide/devshell) with `devShells` (Nix), after all?

1. https://github.com/vic/flake-aspects ?

## Clean Up

1. Consolidate [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix)
   and [`dotfiles/NixOS`](https://github.com/vorburger/dotfiles/tree/main/NixOS) here.

## Docs

1. Blog about my NixOS experience ([similar to this](https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/))

1. Move https://github.com/vorburger/LearningLinux/tree/develop/nix/docs here

1. Move https://github.com/vorburger/LearningLinux/blob/develop/nix/bookmarks.md here

1. Pre-process MD to automagically insert links on anything that looks like a local file path

1. Have an attribute/option in the `modules/**/*.nix` to link to the relevant `docs/*.md`

1. Extract commands from `modules/demo/hello.nix` into `docs/hello.md` etc.

1. Run https://docs.enola.dev/use/execmd

1. Automagically extract TODO list to MD

## Low Priority / Nice to Have

1. https://snowfall.org ?

1. [`nixos-rebuild` alternatives?](docs/docs/reference/nixos-rebuild.md)

1. Suppress (quiet) devshell menu

## Future

1. [Enola.dev](https://docs.enola.dev) AI for https://github.com/NixOS/nixpkgs/pulls ?
