{ self, ... }:
{
  flake.templates = {
    java = {
      path = ../../examples/java;
      description = "Java (Java 25/21, Gradle 9) dev environment";
    };
    java-bun = {
      path = ../../examples/java-bun;
      description = "Java (Java 25/21, Gradle 9) and Bun dev environment";
    };
  };

  perSystem =
    { pkgs, system, ... }:
    let
      # Evaluate Java sub-flake
      javaFlake = import ../../flakes/java/flake.nix;
      javaOutputs =
        (javaFlake.outputs {
          self = javaFlake;
          inherit (self.inputs) nixpkgs;
        })
        // {
          inputs = {
            inherit (self.inputs) nixpkgs;
          };
        };
      javaShell = javaOutputs.devShells.${system}.default;

      # Evaluate Bun sub-flake
      bunFlake = import ../../flakes/bun/flake.nix;
      bunOutputs =
        (bunFlake.outputs {
          self = bunFlake;
          inherit (self.inputs) nixpkgs;
        })
        // {
          inputs = {
            inherit (self.inputs) nixpkgs;
          };
        };
      bunShell = bunOutputs.devShells.${system}.default;

      # Evaluate Java Example flake
      exampleJavaFlake = import ../../examples/java/flake.nix;
      exampleJavaOutputs = exampleJavaFlake.outputs {
        self = exampleJavaFlake;
        java = javaOutputs;
      };
      exampleJavaShell = exampleJavaOutputs.devShells.${system}.default;

      # Evaluate Combined Example flake
      exampleFlake = import ../../examples/java-bun/flake.nix;
      exampleOutputs = exampleFlake.outputs {
        self = exampleFlake;
        java = javaOutputs;
        bun = bunOutputs;
      };
      exampleShell = exampleOutputs.devShells.${system}.default;

      # Check lockfile sync with root nixfiles/flake.lock
      rootLockFile = ../../flake.lock;
      javaLockFile = ../../flakes/java/flake.lock;
      bunLockFile = ../../flakes/bun/flake.lock;
      schemathesisLockFile = ../../flakes/schemathesis/flake.lock;

      rootNixpkgsRev =
        if builtins.pathExists rootLockFile then
          (builtins.fromJSON (builtins.readFile rootLockFile)).nodes.nixpkgs.locked.rev or ""
        else
          "";

      checkLockSyncFor =
        name: lockFile:
        if builtins.pathExists lockFile && rootNixpkgsRev != "" then
          let
            subRev = (builtins.fromJSON (builtins.readFile lockFile)).nodes.nixpkgs.locked.rev or "";
          in
          if subRev != "" && subRev != rootNixpkgsRev then
            throw "flakes/${name}/flake.lock nixpkgs revision (${subRev}) does not match root flake.lock (${rootNixpkgsRev}). Run ./update.sh to synchronize sub-flakes."
          else
            true
        else
          true;

      locksAreSynced =
        checkLockSyncFor "java" javaLockFile
        && checkLockSyncFor "bun" bunLockFile
        && checkLockSyncFor "schemathesis" schemathesisLockFile;
    in
    {
      checks = {
        flake-java =
          pkgs.runCommand "check-flake-java"
            {
              buildInputs = (javaShell.buildInputs or [ ]) ++ (javaShell.nativeBuildInputs or [ ]);
            }
            ''
              java -version
              gradle --version
              touch $out
            '';

        flake-bun =
          pkgs.runCommand "check-flake-bun"
            {
              buildInputs = (bunShell.buildInputs or [ ]) ++ (bunShell.nativeBuildInputs or [ ]);
            }
            ''
              bun --version
              node --version
              touch $out
            '';

        flake-schemathesis =
          let
            schemathesisFlake = import ../../flakes/schemathesis/flake.nix;
            schemathesisOutputs = schemathesisFlake.outputs {
              self = schemathesisFlake;
              inherit (self.inputs) nixpkgs;
            };
          in
          pkgs.runCommand "check-flake-schemathesis"
            {
              buildInputs = [ schemathesisOutputs.packages.${system}.default ];
            }
            ''
              schemathesis --version
              touch $out
            '';

        example-java =
          pkgs.runCommand "check-example-java"
            {
              buildInputs = (exampleJavaShell.buildInputs or [ ]) ++ (exampleJavaShell.nativeBuildInputs or [ ]);
            }
            ''
              java -version
              gradle --version
              touch $out
            '';

        example-java-bun =
          pkgs.runCommand "check-example-java-bun"
            {
              buildInputs = (exampleShell.buildInputs or [ ]) ++ (exampleShell.nativeBuildInputs or [ ]);
            }
            ''
              java -version
              gradle --version
              bun --version
              touch $out
            '';

        subflakes-lock-sync =
          if locksAreSynced then
            pkgs.runCommand "check-subflakes-lock-sync" { } "touch $out"
          else
            pkgs.runCommand "check-subflakes-lock-sync-failed" { } "exit 1";
      };
    };
}
