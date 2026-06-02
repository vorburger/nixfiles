{
  flake.nixosModules.personality-gnome =
    { self, ... }:
    {
      imports = [ self.nixosModules.ui ];

      services.gnome-extra.enable = true;
    };
}
