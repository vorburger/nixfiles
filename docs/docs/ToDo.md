# ToDo

1. https://2026.nixcon.org ?

1. `nrs` script, which does `sudo nixos-rebuild switch --flake .` - AFTER checking that there are no dirty un-committed `nixfiles` AND that they have been pushed to the remote repo.

1. Ixo powersaving: powerctl? tlp?

1. Configure GNOME Keyboard to "German (Switzerland)" instead of ch+de

1. Configure GNOME Power Setttings to Preserve Battery Health

1. Nix lang tutorial

1. Make pre-commit run `nix flake check`

1. Ctrl-R is broken on Console, but works in Kitty on GNOME

1. nix GC automatically

1. Check `systemctl status` and show failures

1. [NUC](https://github.com/NixOS/nixos-hardware/blob/c97bc4d15bd3473dd095e8e8ba57330ab1943a77/flake.nix#L215) as `khany`: Permanently on, with Wireguard

1. Workstation 🖥️ with `pam_u2f.so` for `sudo` with SK

1. Workstation 0.1 (on separate drive; but first backup ToNAS)

1. ZFS; first in VM, then on BM https://wiki.nixos.org/wiki/ZFS

1. `/nix` on separate partition (or LV)

1. How to do LUKS encryption?

   ```nix
   boot.initrd.systemd.enable = true; # Required for modern systemd-cryptsetup
   security.tpm2.enable = true;

   $ sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
   ```

1. [Impermanence](https://www.youtube.com/watch?v=ZKBSWS7OOb4&t=6s) with [`preservation`](https://github.com/nix-community/preservation), see [vimjoyer](https://www.vimjoyer.com/vid89-impermanent)

1. https://wiki.nixos.org/wiki/Secret_Service, consider https://dewaldv.com/posts/2026-03-24-proton-pass-secret-service/ ?

1. Cloud VMs? `imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ]` ? See e.g. [this announcement](https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html).

1. Secure Boot!!
   - Not possible to still dual boot Fedora?
   - Does `ssh-tpm-agent` still work?!

1. Ixo solve <> key map problem (how?)

1. Blog about my NixOS experience ([similar to this](https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/))

## Workstations & Laptops

1. Fix why locale-ch keyboard layout does not work in GNOME VM ... the Settings Keyboard does show ch-de, but the keys aren't mapped correctly. Perhaps this is more of a QEMU than a GNOME thing?

1. Antigravity, but NOT via home-manager, see
   https://github.com/vorburger/dotfiles/commit/21aff996ef847ddeefbde2061f984446682ba1e3

1. Ctrl-Backspace in Fish on Console (only; works over SSH)

1. Alt Left/Right in nano

1. Shift Up/Down, Alt Up/Down, Ctrl PgUp/PgDown
   https://gemini.google.com/app/394387d4e13b598c

1. `pass`, via ext. YK

1. True Colors!! Both on Console, and when logged in remotely over ssh in tmux

1. Try `services.howdy.enable = true; security.pam.services.sudo.howdyAuth = true;`

1. Sound OK? Home Manager `services.pipewire` (new, 2026-04-11; update) options for configuring the PipeWire server etc. https://github.com/vorburger/nixfiles/pull/6

1. Home Manager `services.syshud` (new, 2026-04-12; update) A simple system status indicator for Wayland compositors.

## Nix Common

1. Login and go straight into TMUX

1. `tmux` should remember open tabs over restart

1. Compare `pstree` on Nix Console and Fedora in GNOME

1. Cache on CI

1. `zensical` a https://aifiles.vorburger.ch

1. WiFi setup baked in into installer, as it now is for ixo

1. Use `sopsnix` or `agenix` for secrets management (instead of `nixos-anywhere --extra-files`). Maybe together with https://github.com/Foxboron/age-plugin-tpm ?

1. Try https://github.com/Foxboron/ssh-tpm-agent/issues/109

1. Try https://yazi-rs.github.io

1. Try https://github.com/microvm-nix/microvm.nix?
   See https://michael.stapelberg.ch/posts/2026-02-01-coding-agent-microvm-nix/.

## Upstream

1. Upstream configurations of any services et al. which ideally shouldn't be here at all

1. [ssh-tpm-agent: keyutils](https://github.com/NixOS/nixpkgs/pull/505874)

1. How to isolate? Merely building `ssh-tpm-agent` locally from `nixpkgs` (but probably even standalone) breaks `ssh` on OS.

1. [Add a system service for ssh-tpm-agent](https://github.com/NixOS/nixpkgs/issues/353096)

## Machines

1. VM vorburger sudo password?! None - but enable this:

   ```nix
   security.pam.sshAgentAuth.enable = true;
   security.sudo.extraConfig = ''
   Defaults env_keep += SSH_AUTH_SOCK
   '';
   ```

1. VM with UEFI instead of BIOS, and systemd-boot instead of GRUB

1. `nixos-rebuild ... --specialisation XYZ` for different use cases?

1. Clan!
   - https://docs.clan.lol/guides/nixpkgs-flake-input/
   - https://docs.clan.lol/guides/flake-parts/
   - https://docs.clan.lol/guides/nixos-rebuild/

1. Replace `hostfwd=tcp::2222-:22` with proper bridged networking to get real IP address?

1. Replace StrictHostKeyChecking=no with fixed hostkey from secret vault

1. Have both unstable and fixed nix pkgs - for different hosts

1. Try https://nixcademy.com/posts/auto-growing-nixos-appliance-images-with-systemd-repart/

## Tools

1. https://github.com/maralorn/nix-output-monitor

1. https://github.com/ners/nix-monitored

1. Formatters are a mess; `tools/git-hooks.nix` _pre-commit_ and `fmt.nix` for `nix fmt` don't share .treefmt.toml config?

1. Run `nix flake check` in pre-commit hook

1. Replace [`devshells`](https://github.com/numtide/devshell) with `devShells` (Nix), after all?

1. https://github.com/nix-community/nh ?

1. https://github.com/evanlhatch/ng ?

1. https://github.com/vic/flake-aspects ?

## Clean Up

1. Consolidate [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix)
   and [`dotfiles/NixOS`](https://github.com/vorburger/dotfiles/tree/main/NixOS) here.

## Docs

1. Publish e.g. to `nix.vorburger.ch`

1. Move https://github.com/vorburger/LearningLinux/tree/develop/nix/docs here

1. Move https://github.com/vorburger/LearningLinux/blob/develop/nix/bookmarks.md here

1. Pre-process MD to automagically insert links on anything that looks like a local file path

1. Have an attribute/option in the `modules/**/*.nix` to link to the relevant `docs/*.md`

1. Extract commands from `modules/demo/hello.nix` into `docs/hello.md` etc.

1. Run https://docs.enola.dev/use/execmd

1. Automagically extract TODO list to MD

## Low Priority / Nice to Have

1. How to make `nix` faster? Try alt. impls?

1. https://snowfall.org ?

1. [`nixos-rebuild` alternatives?](reference/nixos-rebuild.md)

1. Suppress (quiet) devshell menu

## Future

1. [Enola.dev](https://docs.enola.dev) AI for https://github.com/NixOS/nixpkgs/pulls ?
