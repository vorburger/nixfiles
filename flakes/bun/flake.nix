{
  description = "Bun and Node.js Toolchain Environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          in
          f { inherit system pkgs; }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, ... }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              bun
              nodejs_26
            ];
          };
        }
      );
    };
}
