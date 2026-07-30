{ inputs, ... }:

{
  # bake the exact revision this image was built from into lachlan's
  # ~/.config/nixos (preservation bind-mounts it from /persist), so the
  # stick can deploy other hosts offline; inputs.self carries no .git —
  # git-clone over it when history is wanted
  systemd.services.seed-nixos-config = {
    description = "Seed ~/.config/nixos with the flake this image was built from";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    # write to the /persist SOURCE, not the bind-mount target: on the first
    # boot of a freshly imaged stick the preservation mounts fail (their
    # sources don't exist yet), so seeding the source both works on boot 1
    # and is exposed by the bind mount from boot 2 onward
    unitConfig.ConditionPathExists = "!/persist/home/lachlan/.config/nixos/flake.nix";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /persist/home/lachlan/.config/nixos
      cp -rT ${inputs.self} /persist/home/lachlan/.config/nixos
      chmod -R u+w /persist/home/lachlan/.config/nixos
      chown -R lachlan:users /persist/home/lachlan
    '';
  };
}
