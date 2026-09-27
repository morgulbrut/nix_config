{ config, ... }:
let
  uid = toString config.users.users.tillo.uid;
  gid = toString config.users.groups.storage.gid;
in
{
  # Assumes modules/nas/system.nix is also imported (storage group,
  # /mnt/storage/media) and base.nix's Docker daemon is enabled.
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers.arm = {
    image = "automaticrippingmachine/automatic-ripping-machine:latest";
    autoStart = true;
    ports = [ "8081:8080" ]; # 8080 is FileBrowser's (modules/filebrowser/system.nix)
    environment = {
      ARM_UID = uid;
      ARM_GID = gid;
    };
    volumes = [
      "/var/lib/arm:/home/arm"
      "/mnt/storage/media/music:/home/arm/music"
      "/var/lib/arm/logs:/home/arm/logs"
      "/mnt/storage/media:/home/arm/media"
      "/var/lib/arm/config:/etc/arm/config"
      "/run/udev:/run/udev:ro"
    ];
    # Three optical drives installed (confirmed on erebor 2026-09-27), passed
    # through by their stable /dev/disk/by-id names rather than raw
    # /dev/srN -- those can renumber if a drive is ever unplugged/reordered,
    # which would otherwise silently hand ARM the wrong physical drive.
    # --privileged + /run/udev above let the container's own udev monitoring
    # see disc-insert events on any of the three, which is how ARM triggers
    # rips automatically.
    extraOptions = [
      "--privileged"
      "--device=/dev/disk/by-id/ata-hp_DVD_RW_AD-7251H5_1974703L21:/dev/sr0"
      "--device=/dev/disk/by-id/ata-hp_DVD-RAM_GH82N_302CC064268:/dev/sr1"
      "--device=/dev/disk/by-id/ata-hp_DVD_D_DH16D6SH_2E7217920529:/dev/sr2"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/arm 0755 ${uid} ${gid} -"
    "d /var/lib/arm/logs 0755 ${uid} ${gid} -"
    "d /var/lib/arm/config 0755 ${uid} ${gid} -"
  ];

  # Auto-rip-on-insert has open reports of flakiness specifically on NixOS
  # (github.com/automatic-ripping-machine/automatic-ripping-machine/issues/1160).
  # If a disc doesn't start ripping on its own, use ARM's web UI at
  # http://erebor:8081 to kick a rip off manually as a fallback.
}
