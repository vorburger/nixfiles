# Nix Systems

```nix
supportedSystems = [
  "x86_64-linux" # 64-bit Intel/AMD Linux
  "aarch64-linux" # 64-bit ARM Linux
  "aarch64-darwin" # 64-bit ARM macOS
];
```

You can just put this into your flake, or use https://github.com/nix-systems/nix-systems.

PS: The `x86_64-darwin` (for 64-bit Intel macOS) is
[no longer suppported by `nixpkgs`](https://nixos.org/manual/nixpkgs/unstable/release-notes#x86_64-darwin-26.05);
see also [this issue](https://github.com/nix-systems/default/issues/1).
