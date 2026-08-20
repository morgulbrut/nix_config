{ lib, pkgs, ... }:
let
  firefoxDesktop = "firefox.desktop";
  firefoxWebHandlers = lib.genAttrs [
    "application/rss+xml"
    "application/xhtml+xml"
    "application/xml"
    "application/vnd.mozilla.xul+xml"
    "text/html"
    "text/xml"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ] (_: [ firefoxDesktop ]);
in
{
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.sessionVariables.BROWSER = "firefox";

  home.packages = with pkgs; [

    # Desktop apps
    # bottles
    chromium
    #discord
    firefox
    gnome-disk-utility
    libreoffice
    #thunar
    #nautilus
    #obsidian
    #qpwgraph
    #qownnotes
    vlc
    wdisplays
    kdePackages.okular
    #obs-studio
    audacity
    art

    # Media tools

    ffmpeg
    sone
    libheif

    # Design tools
    orca-slicer
    kicad
    openscad
    typst
    inkscape  
    gimp-with-plugins

    rustdesk-flutter
    # yt-dlp


    # Music tools
    #chromaprint
    #picard
    #termsonic
  ];

  xdg.mimeApps = {
    enable = true;
    associations.added = firefoxWebHandlers;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "application/pdf" = [ "org.kde.okular.desktop" ];
    } // firefoxWebHandlers;
  };
}
