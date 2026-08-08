_: {
  flake-file.inputs.vorburger-dotfiles = {
    url = "github:vorburger/dotfiles?dir=dotfiles/home-manager";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      home-manager.follows = "home-manager";
      nix-index-database.follows = "nix-index-database";
    };
  };
}
