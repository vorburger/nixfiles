_: {
  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  flake-file.inputs.nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
}
