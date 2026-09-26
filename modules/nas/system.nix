{ pkgs, ... }:
let
  # CHANGEME: fill these in once erebor's drives are physically installed.
  # Find stable identifiers on erebor with `ls -la /dev/disk/by-id/` — never
  # use /dev/sdX directly, those can change across reboots.
  #
  # Add one entry per data disk; the parity disk must be at least as large as
  # the biggest data disk. mergerfs pools the data disks into one tree,
  # SnapRAID gives that pool nightly-synced parity protection (not live
  # redundancy — it protects whatever was on disk at the last sync).
  dataDisks = [
    "/dev/disk/by-id/CHANGEME-disk1"
    "/dev/disk/by-id/CHANGEME-disk2"
  ];
  parityDisk = "/dev/disk/by-id/CHANGEME-parity1";
in
{
  # Pinned (rather than auto-assigned) so other modules — e.g. the ARM
  # container's ARM_UID/ARM_GID — can reference a literal gid at eval time.
  users.groups.storage = {
    gid = 3000;
  };
  users.users.tillo.extraGroups = [ "storage" ];

  fileSystems."/mnt/disk1" = {
    device = builtins.elemAt dataDisks 0;
    fsType = "ext4";
  };
  fileSystems."/mnt/disk2" = {
    device = builtins.elemAt dataDisks 1;
    fsType = "ext4";
  };
  fileSystems."/mnt/parity1" = {
    device = parityDisk;
    fsType = "ext4";
  };

  fileSystems."/mnt/storage" = {
    device = "/mnt/disk1:/mnt/disk2";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs" # write new files to whichever disk has the most free space
    ];
  };

  environment.systemPackages = [
    pkgs.mergerfs
    pkgs.snapraid
  ];

  environment.etc."snapraid.conf".text = ''
    parity /mnt/parity1/snapraid.parity
    content /var/lib/snapraid/snapraid.content
    content /mnt/disk1/.snapraid.content
    content /mnt/disk2/.snapraid.content

    data d1 /mnt/disk1
    data d2 /mnt/disk2

    exclude *.tmp
    exclude /lost+found/
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/snapraid 0750 root root -"
    "d /mnt/storage/media 2775 tillo storage -"
    "d /mnt/storage/media/movies 2775 tillo storage -"
    "d /mnt/storage/media/tv 2775 tillo storage -"
    "d /mnt/storage/media/music 2775 tillo storage -"
  ];

  systemd.services.snapraid-sync = {
    description = "SnapRAID parity sync";
    path = [ pkgs.snapraid ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.snapraid}/bin/snapraid sync";
    };
  };
  systemd.timers.snapraid-sync = {
    description = "Nightly SnapRAID sync";
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.snapraid-scrub = {
    description = "SnapRAID parity scrub";
    path = [ pkgs.snapraid ];
    serviceConfig = {
      Type = "oneshot";
      # Scrub 10% of the array, prioritising blocks not checked in 10+ days.
      ExecStart = "${pkgs.snapraid}/bin/snapraid scrub -p 10 -o 10";
    };
  };
  systemd.timers.snapraid-scrub = {
    description = "Weekly SnapRAID scrub";
    timerConfig = {
      OnCalendar = "Sun 04:00";
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
}
