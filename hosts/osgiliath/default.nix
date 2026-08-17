{pkgs, ... }:
{
  imports = [
    ../common/base.nix
    ../../modules/audio/system.nix
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
    adw-gtk3
    bibata-cursors
  ];
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # tumbler's raw-thumbnailer plugin links libopenraw (which already decodes
  # Canon CR3 fine) but never registered image/x-canon-cr3 in its mime-type
  # list, so .cr3 files never get routed to it. Patch the list rather than
  # waiting on upstream.
  nixpkgs.overlays = [
    (final: prev: {
      tumbler = prev.tumbler.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace plugins/raw-thumbnailer/raw-thumbnailer-provider.c \
            --replace-fail '"image/x-canon-cr2",' '"image/x-canon-cr2",
    "image/x-canon-cr3",'
        '';
      });
    })
  ];
  
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

