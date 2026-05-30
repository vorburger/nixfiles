_: {
  flake.nixosModules.target-vm-1G-grub-8G = _: {
    services.virt-guest = {
      enable = true;
      memorySize = 8192;
      cores = 4;
    };

    boot.loader.grub.enable = true;
    boot.kernelParams = [ "console=ttyS0" ];

    services.getty.autologinUser = "vorburger";
    services.displayManager.autoLogin = {
      enable = true;
      user = "vorburger";
    };
  };
}
