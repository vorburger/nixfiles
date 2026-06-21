# This is an internal helper to reduce boilerplate in ../modules/hosts/.
# It is imported by each host configuration module.
{
  inputs,
  self,
  lib,
}:
{
  mkHost =
    {
      name,
      domain ? "home.vorburger.ch",
      nixpkgs ? inputs.nixpkgs,
      system ? "x86_64-linux",
      diskoDevice ? null,
      diskoModule ? ../modules/disko/_boot-and-ext4.nix,
      useCommon ? true,
      useDefaultUser ? true,
      modules ? [ ],
      testScript ? null,
      enableVMTest ? (testScript != null),
    }:
    let
      inherit (import ./mk-test.nix { inherit inputs self lib; }) mkTest;
    in
    {
      flake.nixosModules.${name} = {
        imports =
          (lib.optional useCommon ../modules/hosts/_common.nix)
          ++ (lib.optional useDefaultUser ../modules/users/_vorburger.nix)
          ++ (lib.optional (diskoDevice != null && diskoModule != null) inputs.disko.nixosModules.disko)
          ++ (lib.optional (diskoDevice != null && diskoModule != null) (
            import diskoModule { device = diskoDevice; }
          ))
          ++ [
            (_: {
              networking.hostName = name;
              networking.domain = domain;
              networking.extraHosts = ''
                127.0.0.1 ${name}.${domain} ${name}
                ::1       ${name}.${domain} ${name}
              '';
            })
          ]
          ++ modules;
      };

      flake.nixosConfigurations.${name} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs self;
          vmTest = false;
          home-manager-module =
            if nixpkgs == inputs.nixpkgs-stable then
              inputs.home-manager-stable.nixosModules.home-manager
            else
              inputs.home-manager.nixosModules.home-manager;
        };
        modules = [ self.nixosModules.${name} ];
      };

      imports = lib.optional enableVMTest (mkTest {
        name = "${name}-boot";
        module = self.nixosModules.${name};
        inherit testScript;
        inherit nixpkgs;
      });
    };
}
