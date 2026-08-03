{ pkgs, ... }:
{
  imports = [
    ../common/base.nix
    ../../audiofix.nix
    ../features/caldigit-ts5-plus.nix
    ../features/hardware-intel.nix
    ../features/flatpak.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "osgiliath";

  environment.systemPackages = with pkgs; [
    #  Add local pacakaged here
    vscode-fhs
    kicad
    platformio
    picocom
    nmap
    typst
    inkscape
  ];
  services.auto-cpufreq.enable = false;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
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

