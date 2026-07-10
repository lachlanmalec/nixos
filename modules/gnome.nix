{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    resources
    gnome-tweaks
  ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.sysprof.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            pkgs.gnomeExtensions.appindicator.extensionUuid
            pkgs.gnomeExtensions.blur-my-shell.extensionUuid
          ];
        };
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
      };
    }
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

    # gnome
    ".config/autostart"
    ".local/share/backgrounds"
    ".local/share/gnome-shell"
    {
      directory = ".config/dconf";
      mode = "0700";
    }
    {
      directory = ".config/goa-1.0";
      mode = "0700";
    }
    {
      directory = ".config/evolution";
      mode = "0700";
    }
    {
      directory = ".local/share/evolution";
      mode = "0700";
    }
    {
      directory = ".local/share/keyrings";
      mode = "0700";
    }
  ];

  # these files are rewritten atomically by GNOME/GTK and cannot be
  # bind-mounted; see the synced-files machinery in persistence.nix
  local.persistence.userSyncedFiles = [
    # wallpaper image written by the "Set as Background" portal
    # (xdg-desktop-portal-gnome writes it here via atomic rename); the
    # picture-uri dconf key points at this path. Settings > Appearance
    # instead stores images in the persisted ~/.local/share/backgrounds.
    ".config/background"
    # monitor layout configured in Display Settings
    ".config/monitors.xml"
    # default application (mime type) choices
    ".config/mimeapps.list"
    # sidebar bookmarks in Files and GTK3/GTK4 file dialogs; the rest of
    # gtk-3.0/gtk-4.0 is managed declaratively / defaults
    ".config/gtk-3.0/bookmarks"
  ];
}
