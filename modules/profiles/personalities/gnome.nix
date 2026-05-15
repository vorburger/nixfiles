{
  flake.nixosModules.personality-gnome =
    { self, ... }:
    {
      imports = [ self.nixosModules.ui ];

      system.stateVersion = "26.05";

      services.gnome-extra.enable = true;
    };
}
