{ ... }:

{
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;
}
