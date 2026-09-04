{
  description = "Example Java Application Development Environment";

  inputs = {
    java.url = "github:vorburger/nixfiles?dir=flakes/java";
  };

  outputs =
    { java, ... }:
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
          in
          f {
            inherit
              system
              pkgs
              javaShell
              ;
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        {
          pkgs,
          javaShell,
          ...
        }:
        {
          default = pkgs.mkShellNoCC {
            inputsFrom = [
              javaShell
            ];

            env = {
              inherit (javaShell) JAVA_HOME;
              inherit (javaShell) GRADLE_HOME;
            };

            shellHook = ''
              ${javaShell.shellHook or ""}
            '';
          };
        }
      );
    };
}
