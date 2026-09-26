{
  # Assumes modules/nas/system.nix (the "storage" group + /mnt/storage/media)
  # is also imported by the host.
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [ "storage" ];

  # No GPU on erebor yet, so transcoding is CPU-only by default (Jellyfin's
  # hardwareAcceleration.type defaults to "none"). Revisit if a GPU is added.

  # First run: open http://erebor:8096 (or the erebor tailnet address) and
  # complete the setup wizard, pointing libraries at /mnt/storage/media/movies,
  # /mnt/storage/media/tv and /mnt/storage/media/music.
}
