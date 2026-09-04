{
  description = "Java & Gradle Toolchain Environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
      ];

      mkJavaDevShell =
        {
          pkgs,
          jdk ? pkgs.openjdk25_headless,
          ideJdk ? pkgs.openjdk21_headless,
          gradle ? (pkgs.gradle_9.override { java = jdk; }),
          extraPackages ? [ ],
          extraVscodeSettings ? { },
          gitHooksScript ? "./scripts/git-hooks-install.sh",
        }:
        let
          buildInputs = [
            gradle
            jdk
            ideJdk
          ]
          ++ extraPackages;

          vscodeSettings = {
            "gradle.autoDetect" = "on";
            "java.configuration.updateBuildConfiguration" = "automatic";
            "java.gradle.buildServer.enabled" = "off";
            "java.import.gradle.experimental.buildServer.enabled" = false;
            "java.import.gradle.enabled" = true;
            "java.import.gradle.home" = "${gradle}";
            "java.import.gradle.version" = "${gradle.version}";
            "java.import.gradle.wrapper.enabled" = false;
            "java.jdt.ls.java.home" = "${ideJdk}/lib/openjdk";
            "java.import.gradle.java.home" = "${ideJdk}/lib/openjdk";
            "gradle.java.home" = "${ideJdk}/lib/openjdk";
            "java.configuration.runtimes" = [
              {
                "name" = "JavaSE-25";
                "path" = "${jdk}/lib/openjdk";
                "default" = true;
              }
              {
                "name" = "JavaSE-21";
                "path" = "${ideJdk}/lib/openjdk";
              }
            ];
            "java.compile.nullAnalysis.mode" = "automatic";
            "java.completion.importOrder" = [
              "#"
              ""
            ];
            "java.completion.favoriteStaticMembers" = [ "com.google.common.truth.Truth.*" ];
            "java.completion.filteredTypes" = [
              "java.awt.*"
              "javax.annotation.*"
              "com.sun.*"
              "com.google.api.client.util.*"
              "com.google.common.base.Optional"
              "sun.*"
              "jdk.*"
              "autovalue.shaded.*"
              "com.github.jsonldjava.shaded.*"
              "com.google.auto.value.extension.serializable.serializer.impl"
              "org.checkerframework.checker.nullness.qual.*"
              "org.eclipse.collections.*"
              "org.graalvm.*"
              "org.junit.*"
              "org.jetbrains.annotations.*"
              "io.micrometer.shaded.*"
              "jakarta.annotation.*"
            ];
            "java.format.enabled" = false;
            "java.format.settings.google.extra" = "--aosp";
            "java.format.settings.google.version" = "1.34.1";
            "java.saveActions.organizeImports" = false;
            "[java]" = {
              "editor.defaultFormatter" = "josevseb.google-java-format-for-vs-code";
              "editor.formatOnSave" = false;
              "editor.codeActionsOnSave" = {
                "source.organizeImports" = "never";
              };
            };
          }
          // extraVscodeSettings;

          settingsJson = builtins.toJSON vscodeSettings;
        in
        pkgs.mkShellNoCC {
          packages = buildInputs;
          env = {
            JAVA_HOME = "${jdk}";
            GRADLE_HOME = "${gradle}";
          };
          shellHook = ''
            # Auto-generate .vscode/settings.json, but only if the content actually
            # changed, to avoid invalidating Gradle's configuration cache on every run.
            mkdir -p .vscode
            _new_settings=${pkgs.lib.escapeShellArg settingsJson}
            if [ "$(cat .vscode/settings.json 2>/dev/null)" != "$_new_settings" ]; then
              echo "$_new_settings" > .vscode/settings.json
            fi

            # Clean up unpatched embedded JRE in VS Code extensions on NixOS to ensure
            # VS Code Gradle and Java extensions use the Nix-provided Java runtime.
            rm -rf "$HOME/.vscode/extensions"/redhat.java-*/jre 2>/dev/null || true

            # Auto-install git hooks if script exists
            if [ -f "${gitHooksScript}" ] && [ -d .git ]; then
              ${gitHooksScript}
            fi
          '';
        };

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
      lib = {
        inherit mkJavaDevShell;
      };

      devShells = forEachSupportedSystem (
        { pkgs, ... }:
        {
          default = mkJavaDevShell { inherit pkgs; };
          build = pkgs.mkShellNoCC {
            packages = [
              (pkgs.gradle_9.override { java = pkgs.openjdk25_headless; })
              pkgs.openjdk25_headless
              pkgs.openjdk21_headless
            ];
            env = {
              JAVA_HOME = "${pkgs.openjdk25_headless}";
              GRADLE_HOME = "${pkgs.gradle_9}";
            };
          };
        }
      );
    };
}
