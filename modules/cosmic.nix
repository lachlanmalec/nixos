{ ... }:

{
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;

  # greeter state (mirrors each user's greeter-relevant settings)
  local.persistence.systemDirectories = [
    "/var/lib/cosmic-greeter"
  ];

  local.persistence.userDirectories = [
    # xdg user directories
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Projects"
    "Public"
    "Templates"
    "Videos"

    # cosmic (settings are a tree of small files, safe to bind mount)
    ".config/cosmic"
    ".local/share/cosmic"
    ".local/state/cosmic"
  ];

  # default application (mime type) choices; rewritten atomically, see the
  # synced-files machinery in persistence.nix
  local.persistence.userSyncedFiles = [
    ".config/mimeapps.list"
  ];
}
