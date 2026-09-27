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
    ./hardware-configuration.nix
  ];

  networking.hostName = "osgiliath";

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
  fileSystems."/mnt/nas" = {
    device = "erebor.local:/mnt/storage";
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

