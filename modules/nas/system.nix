{ pkgs, ... }:
let
  # Real disk identifiers from erebor, recorded when the arrays were built
  # (2026-09-27): 2x6TB Seagate IronWolf mirrored as md0, 2x2TB WD Red
  # mirrored as md1, mergerfs pools the two mirrors into one tree. Every
  # branch of the pool is itself live-redundant (RAID1), unlike SnapRAID's
  # nightly-synced parity.
  mirror6t = "/dev/disk/by-uuid/44a36316-da13-4e48-959a-4acb8bd4b81e"; # md0, ext4
  mirror2t = "/dev/disk/by-uuid/9e9729e9-5fbd-4a4a-a713-29add28a9889"; # md1, ext4

  # A missing/degraded array shouldn't stop the box booting (it needs to stay
  # reachable over SSH/tailscale to fix it).
  diskOptions = [
    "nofail"
    "x-systemd.device-timeout=10s"
  ];
in
{
  # Needed for the two mdadm RAID1 arrays (md0 = 6TB pair, md1 = 2TB pair) to
  # be detected and assembled automatically at boot.
  boot.swraid.enable = true;

  environment.etc."mdadm.conf".text = ''
    ARRAY /dev/md0 metadata=1.2 UUID=99e187e6:30787339:52c5d3a3:741990b8 name=erebor:storage6t
    ARRAY /dev/md1 metadata=1.2 UUID=9bf89c25:4701d381:8a1bb8f7:e05e4cbc name=erebor:storage2t

    # mdmonitor refuses to run at all (fails at startup) without one of
    # these set, even though there's no MTA on erebor to actually deliver
    # mail — this just satisfies that check. Revisit with a real alert path
    # (e.g. a PROGRAM script hitting ntfy/ a webhook) if that matters later.
    MAILADDR root
  '';

  # Pinned (rather than auto-assigned) so other modules — e.g. the ARM
  # container's ARM_UID/ARM_GID — can reference a literal gid at eval time.
  users.groups.storage = {
    gid = 3000;
  };
  users.users.tillo.extraGroups = [ "storage" ];

  fileSystems."/mnt/storage6t" = {
    device = mirror6t;
    fsType = "ext4";
    options = diskOptions;
  };
  fileSystems."/mnt/storage2t" = {
    device = mirror2t;
    fsType = "ext4";
    options = diskOptions;
  };

  fileSystems."/mnt/storage" = {
    device = "/mnt/storage6t:/mnt/storage2t";
    fsType = "fuse.mergerfs";
    options = [
      "nofail"
      # Don't mount the pool if a branch is missing, otherwise uploads would
      # silently land on the root filesystem under the empty mountpoint.
      "x-systemd.requires-mounts-for=/mnt/storage6t"
      "x-systemd.requires-mounts-for=/mnt/storage2t"
      "defaults"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs" # write new files to whichever branch has the most free space
    ];
  };

  environment.systemPackages = [
    pkgs.mergerfs
    pkgs.mdadm
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/storage/media 2775 tillo storage -"
    "d /mnt/storage/media/movies 2775 tillo storage -"
    "d /mnt/storage/media/tv 2775 tillo storage -"
    "d /mnt/storage/media/music 2775 tillo storage -"
  ];

  # RAID1 doesn't need SnapRAID-style parity sync, but scrubbing periodically
  # still catches silent bitrot before it's mirrored as "correct" onto the
  # other disk.
  systemd.services.raid-scrub = {
    description = "RAID1 array scrub (bitrot check)";
    path = [ pkgs.coreutils ];
    script = ''
      for md in md0 md1; do
        echo check > /sys/block/$md/md/sync_action
      done
    '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.raid-scrub = {
    description = "Monthly RAID1 scrub";
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  # LAN + tailnet file access. Set tillo's Samba password once, after the
  # first rebuild, with: sudo smbpasswd -a tillo
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "erebor";
        "security" = "user";
      };
      storage = {
        path = "/mnt/storage";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "tillo";
        "force group" = "storage";
        "create mask" = "0664";
        "directory mask" = "2775";
      };
    };
  };
  systemd.services.samba-smbd.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];

  # NFS export so other Linux boxes (e.g. osgiliath) can mount the pool
  # directly instead of going through Samba. all_squash + anon uid/gid means
  # every client acts as tillo:storage regardless of its own local uid
  # numbering -- simpler and more robust than relying on uids matching
  # across machines.
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/storage 192.168.0.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=3000) 100.64.0.0/10(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=3000)
    '';
  };
  systemd.services.nfs-server.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];

  networking.firewall.allowedTCPPorts = [ 2049 ];
  networking.firewall.allowedUDPPorts = [ 2049 ];
}
