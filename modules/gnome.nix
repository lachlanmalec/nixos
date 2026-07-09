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
}
