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
      system ? "x86_64-linux",
      diskoDevice ? null,
      useCommon ? true,
      useDefaultUser ? true,
      modules ? [ ],
      testScript ? null,
    }:
    let
      inherit (import ./mk-test.nix { inherit inputs self lib; }) mkTest;
    in
    {
      flake.nixosModules.${name} = {
        imports =
          (lib.optional useCommon ../modules/hosts/_common.nix)
          ++ (lib.optional useDefaultUser ../modules/users/_vorburger.nix)
          ++ (lib.optional (diskoDevice != null) inputs.disko.nixosModules.disko)
          ++ (lib.optional (diskoDevice != null) (
            import ../modules/disko/_boot-and-ext4.nix { device = diskoDevice; }
          ))
          ++ [
            (_: {
              networking.hostName = name;
            })
          ]
          ++ modules;
      };

      flake.nixosConfigurations.${name} = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [ self.nixosModules.${name} ];
      };

      imports = lib.optional (testScript != null || name != "installer") (
        mkTest "${name}-boot" self.nixosModules.${name} testScript
      );
    };
}
