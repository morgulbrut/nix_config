{pkgs, ... }:
{
  imports = [
    ../common/base.nix
    ../../modules/audio/system.nix
    ../../modules/caldigit-ts5-plus/system.nix
    ../../modules/hardware-intel/system.nix
    ../../modules/flatpak/system.nix
    ../../modules/gaming/system.nix
    ../../modules/lutris/system.nix
    ../../modules/noctalia-drive-health/system.nix
    ./hardware-configuration.nix
    ./storage.nix
  ];

  networking.hostName = "osgiliath";

  services.auto-cpufreq.enable = false;


  programs.xfconf.enable = true;
  environment.systemPackages = with pkgs; [
    papirus-icon-theme
    xfce.thunar
  ];
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
  
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

