_: {
  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  # NB: nixos-hardware does not use nixpkgs itself, so no "follows" (here)
}
