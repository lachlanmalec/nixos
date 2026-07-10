{ ... }:

{
  services = {
    desktopManager.plasma6.enable = true;
    displayManager.plasma-login-manager.enable = true;
  };

  # login manager state (last user/session)
  local.persistence.systemDirectories = [
    "/var/lib/plasmalogin"
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

    # kde
    ".config/kdedefaults"
    ".config/plasma-workspace"
    ".config/kde.org"
    ".config/session" # window session restore
    ".local/share/plasma" # installed widgets and desktop themes
    ".local/share/kscreen" # monitor layouts (plasma 5 format)
    ".local/share/kactivitymanagerd"
    ".local/share/konsole"
    ".local/share/dolphin"
    {
      directory = ".local/share/kwalletd"; # kde wallet (secrets)
      mode = "0700";
    }
    # deliberately ephemeral: .local/share/baloo (file search index,
    # regenerable)
  ];

  # kconfig rc files are rewritten atomically and live loose in ~/.config;
  # see the synced-files machinery in persistence.nix
  local.persistence.userSyncedFiles = [
    # global look and feel, colors, fonts
    ".config/kdeglobals"
    # window manager: effects, rules, screen edges
    ".config/kwinrc"
    # monitor configuration (plasma 6, the kde analogue of monitors.xml)
    ".config/kwinoutputconfig.json"
    # workspace and shell behaviour
    ".config/plasmarc"
    ".config/plasmashellrc"
    # desktop layout: panels, widgets, wallpaper
    ".config/plasma-org.kde.plasma.desktop-appletsrc"
    # shortcuts and input
    ".config/kglobalshortcutsrc"
    ".config/khotkeysrc"
    ".config/kcminputrc"
    ".config/kxkbrc"
    # lock screen, launcher, session, power
    ".config/kscreenlockerrc"
    ".config/krunnerrc"
    ".config/ksmserverrc"
    ".config/powerdevilrc"
    # wallet and file indexing configuration
    ".config/kwalletrc"
    ".config/baloofilerc"
    # applications
    ".config/dolphinrc"
    ".config/konsolerc"
    ".config/spectaclerc"
    # default application (mime type) choices
    ".config/mimeapps.list"
    # gtk app theming written by kde-gtk-config
    ".config/gtk-3.0/settings.ini"
    ".config/gtk-4.0/settings.ini"
  ];
}
