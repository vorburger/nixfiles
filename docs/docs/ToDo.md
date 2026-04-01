# ToDo

## Nix

1. SSH with TPM but also still touch or other confirmation

1. Alt Left/Right in nano

1. Shift Up/Down, Alt Up/Down, Ctrl PgUp/PgDown
   https://gemini.google.com/app/394387d4e13b598c

1. `pass`, via ext. YK

1. True Colors!! Both on Console, and when logged in remotely over ssh in tmux

1. Ctrl-Backspace in Fish on Console (only; works over SSH)

1. How to solve <> problem

1. Try `services.howdy.enable = true; security.pam.services.sudo.howdyAuth = true;`

1. https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/x1/12th-gen/default.ni

1. nix GC automatically

1. Login and go straight into TMUX

1. Graphical; initially most minimal - just Brave & Kitty, in Sway?

1. Compare `pstree` on Nix Console and Fedora in GNOME

1. Antigravity, but NOT via home-manager, see
   https://github.com/vorburger/dotfiles/commit/21aff996ef847ddeefbde2061f984446682ba1e3

1. Make a much more minimal initial host config

1. WiFi setup baked in into installer, as it now is for ixo

1. How to do LUKS encryption?

1. Impermanence

1. `/nix` on separate partition (or LV)

1. #AI extract an `_local.nix` from vm1/configuration.nix, re-use it in ixo/configuration.nix

1. #AI Make nixos-anywhere available in the dev shell of this project

1. Use `sopsnix` or `agenix` for secrets management (instead of `nixos-anywhere --extra-files`)

1. `nrs` script, which does `sudo nixos-rebuild switch --flake .` - AFTER checking that there are no dirty un-committed `nixfiles` AND that they have been pushed to the remote repo.

1. Move `nix-update` skill to `nixfiles` repo - but reference it as input to make it available here... how?

1. Blog about my NixOS experience ([similar to this](https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/))

1. Try https://github.com/microvm-nix/microvm.nix?
   See https://michael.stapelberg.ch/posts/2026-02-01-coding-agent-microvm-nix/.

## Machines

1. VM vorburger sudo password?! None - but enable this:

   ```nix
   security.pam.sshAgentAuth.enable = true;
   security.sudo.extraConfig = ''
   Defaults env_keep += SSH_AUTH_SOCK
   '';
   ```

1. Remove Disko & GRUB from test1, if possible

1. VM with UEFI instead of BIOS, and systemd-boot instead of GRUB

1. Rename `test1` to vm-without-bootloader, and vm1 to vm-bios-with-grub-bootloader ?

1. VM testing; https://github.com/anatol/vmtest for `systemctl status` (porcelaim?)

1. `nixos-rebuild ... --specialisation XYZ` for different use cases?

1. Cloud VMs? `imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ]` ? See e.g. [this announcement](https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html).

1. Workstation 🖥️ with `pam_u2f.so` for `sudo` with SK

1. Clan!
   - https://docs.clan.lol/guides/nixpkgs-flake-input/
   - https://docs.clan.lol/guides/flake-parts/
   - https://docs.clan.lol/guides/nixos-rebuild/

1. Replace `hostfwd=tcp::2222-:22` with proper bridged networking to get real IP address?

1. Replace StrictHostKeyChecking=no with fixed hostkey from secret vault

1. Have both unstable and fixed nix pkgs - for different hosts

1. Try https://nixcademy.com/posts/auto-growing-nixos-appliance-images-with-systemd-repart/

## Gemini CLI

1. Reads all `docs/**.md` in GEMINI.md ?!

1. Despite `.gemini/settings.json` it still asks for confirmation to run `nix fmt` - why?

## Tools

1. Make `bin/vm.sh` a `modules/tools/vm.nix` command available in devshell as `vm`

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

1. Automagically extract TODO list

## Low Priority / Nice to Have

1. [`nixos-rebuild` alternatives?](reference/nixos-rebuild.md)

1. Suppress (quiet) devshell menu

## Future

1. [Enola.dev](https://docs.enola.dev) AI for https://github.com/NixOS/nixpkgs/pulls ?
