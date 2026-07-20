{
  flake.nixosModules.personality-gnome =
    {
      pkgs,
      lib,
      self,
      ...
    }:
    {
      imports = [ self.nixosModules.ui ];

      services.gnome-extra.enable = true;

      environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
          (
            with pkgs.gst_all_1;
            [
              gst-plugins-good
              gst-plugins-bad
              gst-plugins-ugly
              gst-libav
            ]
          );
    };
}
