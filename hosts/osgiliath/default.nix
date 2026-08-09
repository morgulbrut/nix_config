{pkgs, ... }:
{
  imports = [
    ../common/base.nix
    ../../audiofix.nix
    ../features/caldigit-ts5-plus.nix
    ../features/hardware-intel.nix
    ../features/flatpak.nix
    ../features/gaming.nix
    ../features/lutris.nix
    ../features/noctalia-drive-health
    ./hardware-configuration.nix
    ./storage.nix
  ];

  networking.hostName = "osgiliath";

  environment.systemPackages = with pkgs; [
    #  Add local pacakaged here
  ];
  services.auto-cpufreq.enable = false;

  programs.xfconf.enable = true;
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

