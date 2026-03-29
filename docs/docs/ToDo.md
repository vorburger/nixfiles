# ToDo

## Nix

1. Gemini CLI

1. Ctrl key mapping

1. How to solve <> problem

1. Smarter `sudo` - pick up _Allow user to run nixos-rebuild without password (current)_ chat re. `sudo`, try:
   - `services.fprintd.enable = true; security.pam.services.sudo.fprintAuth = true;`
     Then you enroll with `fprintd-enroll`.
   - Try `services.howdy.enable = true; security.pam.services.sudo.howdyAuth = true;`
   - YK, after all? But battery... vs TPM?
   Revert https://github.com/vorburger/nixfiles/commit/68714121b6aa42efd2d428a2070cbebe459f564e

1. SSH with TPM but also still touch or other confirmation

1. home-manager

1. alias j - needs autojump?

1. https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/x1/12th-gen/default.nix

1. TMUX in Console

1. nix GC automatically

1. `pass`, via ext. YK

1. Graphical

1. Make a much more minimal initial host config

1. WiFi setup baked in into installer, as it now is for ixo

1. #AI extract an `_local.nix` from vm1/configuration.nix, re-use it in ixo/configuration.nix

1. #AI Make nixos-anywhere available in the dev shell of this project

1. Use `sopsnix` or `agenix` for secrets management (instead of `nixos-anywhere --extra-files`)

1. Move `nix-update` skill to `nixfiles` repo - but reference it as input to make it available here... how?

1. Blog about my NixOS experience ([similar to this](https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/))

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

1. Rename test1 to vm-without-bootloader, and vm1 to vm-bios-with-grub-bootloader ?

1. VM testing; https://github.com/anatol/vmtest for `systemctl status` (porcelaim?)

1. `nixos-rebuild ... --specialisation XYZ` for different use cases?

1. How to do LUKS encryption?

1. Impermanence

1. `/nix` on separate partition (or LV)

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
   and [`dotfiles/NixOS`](https://github.com/vorburger/vorburger-dotfiles-bin-etc/tree/main/NixOS) here.

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
