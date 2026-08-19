{pkgs, ... }:
{
  imports = [
    ../common/base.nix
    ../../modules/audio/system.nix
    ../../modules/thunar/system.nix
    ../../modules/hardware-intel/system.nix
    ../../modules/flatpak/system.nix
    ../../modules/gaming/system.nix
    ../../modules/lutris/system.nix
    ../../modules/noctalia-drive-health/system.nix
    ../../modules/virtualisation/system.nix
    ./hardware-configuration.nix
    ./storage.nix
  ];

  networking.hostName = "osgiliath";

  services.auto-cpufreq.enable = false;

  boot.kernelParams = [ "usbcore.autosuspend=-1" ];
  
  services.udev.packages = with pkgs; [ platformio-core.udev ];
  
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

