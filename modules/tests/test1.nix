{ inputs, self, ... }:
import ../tools/_mk-test.nix { inherit inputs self; } "test1-boot" self.nixosModules.test1
