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
    unitConfig = {
      ConditionPathExists = "!/home/lachlan/.config/nixos/flake.nix";
      # skip seeding if the preservation bind mount failed, rather than
      # copying the flake into the tmpfs root where it evaporates on reboot
      RequiresMountsFor = "/home/lachlan/.config/nixos";
    };
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /home/lachlan/.config/nixos
      cp -rT ${inputs.self} /home/lachlan/.config/nixos
      chmod -R u+w /home/lachlan/.config/nixos
      chown -R lachlan:users /home/lachlan/.config/nixos
    '';
  };
}
