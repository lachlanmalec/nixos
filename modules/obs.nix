{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;

    # optional Nvidia hardware acceleration
    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
    ];
  };

  # obs-studio (scenes, profiles incl. stream keys, settings)
  local.persistence.userDirectories = [
    {
      directory = ".config/obs-studio";
      mode = "0700";
    }
  ];
}
