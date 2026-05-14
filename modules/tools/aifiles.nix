{ inputs, ... }:
{
  flake-file.inputs.aifiles = {
    url = "github:vorburger/aifiles";
    flake = false;
  };

  perSystem = _: {
    devshells.default = {
      devshell.startup.aifiles.text = ''
        # Symlink AI skills from https://github.com/vorburger/aifiles
        mkdir -p .agents/
        if [ -e .agents/skills ] && [ ! -L .agents/skills ]; then
          rm -rf .agents/skills
        fi
        ln -sfn "${inputs.aifiles}/skills" .agents/skills
      '';
    };
  };
}
