{ pkgs, ... }:
{
  # Personal collection of development tools.
  environment.systemPackages = [
    pkgs.gnumake
    pkgs.go
    pkgs.gcc
  ];
}
