_: {
  flake.nixosModules.target-vm-256M-grub-512M = _: {
    services.virt-guest = {
      enable = true;
      memorySize = 512;
      cores = 1;
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
