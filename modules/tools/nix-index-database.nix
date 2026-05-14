_: {
  flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  flake-file.inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
}
