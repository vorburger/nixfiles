# ToDo

## Machines

1. Make `bin/vm.ssh` wait for port 2222 to be open

1. Modularize `modules/hosts/test1.nix`

1. Review and merge `modules/hosts/default.nix` vs `bin/vm.sh`

1. VM installation!

1. VM testing

1. https://flake.parts/options/disko.html ?

1. Cloud VMs? `imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ]` ? See e.g. [here](https://www.haskellforall.com/2023/01/announcing-nixos-rebuild-new-deployment.html).

1. Clan!
   - https://docs.clan.lol/guides/nixpkgs-flake-input/
   - https://docs.clan.lol/guides/flake-parts/
   - https://docs.clan.lol/guides/nixos-rebuild/

1. Replace `hostfwd=tcp::2222-:22` with proper bridged networking to get real IP address?

1. Replace StrictHostKeyChecking=no with fixed hostkey from secret vault

## Gemini CLI

1. Despite `.gemini/settings.json` it still asks for confirmation to run `nix fmt` - why?

## Tools

1. Make `bin/vm.sh` a `modules/tools/vm.nix` command available in devshell as `vm`

1. Formatters are a mess; `tools/git-hooks.nix` _pre-commit_ and `fmt.nix` for `nix fmt` don't share .treefmt.toml config?

1. Run `nix flake check` in pre-commit hook

1. Replace [`devshells`](https://github.com/numtide/devshell) with `devShells` (Nix), after all?

1. https://github.com/vic/flake-aspects ?

## Clean Up

1. Consolidate [`LearningLinux` 🐧 repo](https://github.com/vorburger/LearningLinux/tree/develop/nix)
   and [`dotfiles/NixOS`](https://github.com/vorburger/vorburger-dotfiles-bin-etc/tree/main/NixOS) here.

## Docs

1. `docs/` with https://flake.parts/options/mkdocs-flake.html

1. Move https://github.com/vorburger/LearningLinux/tree/develop/nix/docs here

1. Move https://github.com/vorburger/LearningLinux/blob/develop/nix/bookmarks.md here

1. Pre-process MD to automagically insert links on anything that looks like a local file path

1. Have an attribute/option in the `modules/**/*.nix` to link to the relevant `docs/*.md`

1. Extract commands from `modules/demo/hello.nix` into `docs/hello.md` etc.

1. Run https://docs.enola.dev/use/execmd

1. Publish e.g. to `nix.vorburger.ch`

1. Automagically extract TODO list

## Low Priority / Nice to Have

1. [`nixos-rebuild` alternatives?](docs/nixos-rebuild.md)

1. Suppress (quiet) devshell menu
