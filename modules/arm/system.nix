{ config, pkgs, ... }:
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
    #
    # --network=host is required for auto-rip-on-insert to work at all:
    # ARM runs its own udevd inside the container (visible in its boot log),
    # but Linux uevents are broadcast over a netlink socket that's scoped to
    # the network namespace they originate in. Without host networking, the
    # container's udevd sits in an isolated netns and never receives the
    # host's disc-insert events -- confirmed on erebor: zero jobs ever in
    # ARM's own database despite inserting a CD, with device passthrough
    # otherwise working fine (drives correctly detected at boot). No port
    # mapping needed/possible in host mode; see WEBSERVER_PORT below for how
    # ARM's own UI ends up on :8081 instead of its default :8080 (which
    # FileBrowser already owns) without one.
    extraOptions = [
      "--privileged"
      "--network=host"
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

  # ARM generates arm.yaml itself on first run (not something we template),
  # defaulting WEBSERVER_PORT to 8080. Host networking means Docker's own
  # port mapping no longer applies -- the app binds whatever port is in its
  # own config directly on the host -- so pin it to 8081 (FileBrowser owns
  # 8080) every time the container starts, idempotently, self-healing even
  # if the file is ever regenerated.
  systemd.services.docker-arm.preStart = ''
    if [ -f /var/lib/arm/config/arm.yaml ]; then
      ${pkgs.gnused}/bin/sed -i 's/^WEBSERVER_PORT:.*/WEBSERVER_PORT: 8081/' /var/lib/arm/config/arm.yaml
    fi
  '';

  # Auto-rip-on-insert has open reports of flakiness specifically on NixOS
  # (github.com/automatic-ripping-machine/automatic-ripping-machine/issues/1160).
  # If a disc doesn't start ripping on its own, use ARM's web UI at
  # http://erebor:8081 to kick a rip off manually as a fallback.
}
