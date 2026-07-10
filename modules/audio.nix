{ ... }:

{
  # enable rtkit to help with audio latency
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # WirePlumber records the default sink/source and per-device/per-stream
  # volumes here (default-nodes, default-routes, restore-stream, ...). It
  # rewrites files atomically inside this directory, so bind-mounting the whole
  # directory is safe (unlike a per-file mount). Without this the selection and
  # volumes reset on every boot.
  local.persistence.userDirectories = [
    {
      directory = ".local/state/wireplumber";
      mode = "0700";
    }
  ];
}
