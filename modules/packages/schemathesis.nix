{ self, ... }:
{
  perSystem =
    { system, ... }:
    let
      schemathesisFlake = import ../../flakes/schemathesis/flake.nix;
      schemathesisOutputs = schemathesisFlake.outputs {
        self = schemathesisFlake;
        inherit (self.inputs) nixpkgs;
      };
    in
    {
      packages.schemathesis = schemathesisOutputs.packages.${system}.schemathesis;
    };
}
