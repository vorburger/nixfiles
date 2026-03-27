---
name: nix-update
description: Update Nix flake inputs.
metadata:
  author: "Gemini CLI"
---

# Nix Update

This skill provides a robust way to update all flake inputs of a Nix project iteratively. Unlike a bulk `nix flake update`, this skill verifies each input's update independently to ensure stability. If a check fails, the specific input update is reverted while others continue. Use this when you want to safely update all flake dependencies one by one

## Core Logic

For every root input in the `flake.lock`:

1. **Backup**: Create a temporary backup of `flake.lock`.
2. **Update**: Run `nix flake update <input_name>`.
3. **Validate**: Run `nix flake check` to ensure the flake remains in a valid state.
4. **Commit/Revert**:
   - If validation succeeds: Keep the change and track it as successful.
   - If validation fails: Restore `flake.lock` from backup and track it as failed.
5. **Summary**: At the end of the script, a clear summary of all successful and failed updates is printed to the terminal.

## Usage

Execute the update script from the project root:

```bash
bash .agents/skills/nix-update/scripts/nix-update.sh
```

## Dependencies

- `nix`: The Nix package manager with flakes enabled.
- `jq`: Required to parse the flake inputs.
- `bash`: Required to run the automation script.

## Troubleshooting

- **`nix flake check` fails due to formatting**: Because `nix flake check` typically executes `treefmt` (or similar formatters) to verify repository-wide format compliance, having unformatted, modified files (even non-nix files like this shell script) in the working tree will cause the check to fail. **Solution**: Run `nix fmt` before running this script to ensure all files in your repository meet the formatting standards.
