{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs }:
    {
      packages.x86_64-linux.cow = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "hello-cow" ''
        ${nixpkgs.legacyPackages.x86_64-linux.cowsay}/bin/cowsay "Hello, Nixian!"
      '';
    };
}
