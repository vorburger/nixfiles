_: {
  # nix-fast-build *IS* in nixpkgs, but we want the latest and greatest, e.g. for https://github.com/Mic92/nix-fast-build/issues/341
  flake-file.inputs.nix-fast-build.url = "github:Mic92/nix-fast-build";
  flake-file.inputs.nix-fast-build.inputs.nixpkgs.follows = "nixpkgs";
  flake-file.inputs.nix-fast-build.inputs.flake-parts.follows = "flake-parts";
  flake-file.inputs.nix-fast-build.inputs.treefmt-nix.follows = "treefmt-nix";

  perSystem =
    { inputs', ... }:
    {
      packages.nix-fast-build = inputs'.nix-fast-build.packages.nix-fast-build.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          substituteInPlace $out/lib/python*/site-packages/nix_fast_build/processes.py \
            --replace 'if proc.returncode is not None:' 'if proc.returncode is None:'
        '';
      });
    };
}
