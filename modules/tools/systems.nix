_: {
  systems = [
    "x86_64-linux"

    # Maybe later?
    # "aarch64-linux"
    # "aarch64-darwin"

    # WITHOUT "x86_64-darwin", due to:
    #   - https://nixos.org/manual/nixpkgs/unstable/release-notes#x86_64-darwin-26.05
    #   - https://github.com/nix-systems/default/issues/1
  ];
}
