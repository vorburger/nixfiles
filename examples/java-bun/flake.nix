{
  description = "Example Java & Bun Application Development Environment";

  inputs = {
    java.url = "github:vorburger/nixfiles?dir=flakes/java";

    bun = {
      url = "github:vorburger/nixfiles?dir=flakes/bun";
      inputs.nixpkgs.follows = "java/nixpkgs";
    };
  };

  outputs =
    {
      java,
      bun,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];
      forEachSupportedSystem =
        f:
        java.inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          let
            pkgs = java.inputs.nixpkgs.legacyPackages.${system};
            javaShell = java.devShells.${system}.default;
            bunShell = bun.devShells.${system}.default;
          in
          f {
            inherit
              system
              pkgs
              javaShell
              bunShell
              ;
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        {
          pkgs,
          javaShell,
          bunShell,
          ...
        }:
        {
          default = pkgs.mkShellNoCC {
            # Combine packages from both Java and Bun sub-flakes
            inputsFrom = [
              javaShell
              bunShell
            ];

            # Inherit environment variables
            env = {
              inherit (javaShell) JAVA_HOME;
              inherit (javaShell) GRADLE_HOME;
            };

            # Merge shell hooks (VS Code settings generation, JRE cleanup, etc.)
            shellHook = ''
              ${javaShell.shellHook or ""}
              ${bunShell.shellHook or ""}
            '';
          };
        }
      );
    };
}
