{pkgs, ... }:
{
  imports = [
    ../common/base.nix
    ../common/desktop.nix
    ../../modules/audio/system.nix
    ../../modules/thunar/system.nix
    ../../modules/printing/system.nix
    ../../modules/hardware-intel/system.nix
    ../../modules/flatpak/system.nix
    ../../modules/gaming/system.nix
    ../../modules/lutris/system.nix
    ../../modules/noctalia-drive-health/system.nix
    ../../modules/virtualisation/system.nix
    ../../modules/tailscale/system.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "osgiliath";

  # Key-only, reachable on the tailnet and the LAN -- lets osgiliath act as
  # an SSH jump host to erebor from outside the house (`ssh -J osgiliath
  # erebor`) using the same authorized_keys list as erebor
  # (hosts/common/base.nix), without needing erebor itself exposed.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.auto-cpufreq.enable = false;

  boot.kernelParams = [ "usbcore.autosuspend=-1" ];
  
  services.udev.packages = with pkgs; [ platformio-core.udev ];

  # gid must match modules/nas/system.nix on erebor -- not strictly required
  # for access (the NFS export below squashes every client to tillo:storage
  # regardless), but keeps `ls -l` showing "storage" instead of a raw number.
  users.groups.storage = {
    gid = 3000;
  };
  users.users.tillo.extraGroups = [ "storage" ];

  # NFS mount of erebor's NAS pool. Automount (mounts on first access, not
  # at boot) plus nofail so boot never blocks on erebor being reachable.
  #
  # Device path is "/", not "/mnt/storage": the export has fsid=0
  # (modules/nas/system.nix, required since mergerfs has no stable device
  # number of its own), which makes that export *become* the NFSv4
  # pseudo-root rather than just identifying it -- "/mnt/storage" doesn't
  # exist in the NFSv4 namespace at all once that's set. Verified directly:
  # mounting "erebor:/mnt/storage" fails ENOENT, "erebor:/" is the same
  # content and works.
  fileSystems."/mnt/nas" = {
    device = "erebor.local:/";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.device-timeout=10s"
      "_netdev"
    ];
  };

  # Fortnightly-ish backup of ~/Data to the NAS (1st and 15th of each month;
  # Persistent catches up on the next boot if the machine was off). Plain
  # rsync without --delete, so files removed locally stay in the backup.
  # Accessing /mnt/nas triggers the NFS automount above.
  systemd.services.data-backup = {
    description = "Back up /home/tillo/Data to /mnt/nas/bkp";
    serviceConfig = {
      Type = "oneshot";
      User = "tillo";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    path = [ pkgs.rsync ];
    script = ''
      mkdir -p /mnt/nas/bkp/Data
      rsync -a --no-owner --no-group --partial /home/tillo/Data/ /mnt/nas/bkp/Data/
    '';
  };
  systemd.timers.data-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-01,15 03:00";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}

