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
  home.sessionVariables.BROWSER = "firefox";

  home.packages = with pkgs; [
    # Core utilities
    clinfo
    cliphist
    fastfetch
    ponysay
    ripgrep
    stow
    unzip
    wget
    nmap
    wl-clipboard
    eza
    fzf
    btop
    lolcat
    fd
    tldr
    atuin
    erdtree
    smartmontools

    # Desktop apps
    bottles
    chromium
    #discord
    firefox
    gnome-disk-utility
    libreoffice
    thunar
    #nautilus
    #obs-studio
    #obsidian
    #qpwgraph
    #qownnotes
    vlc
    wdisplays
    kdePackages.okular
    art

    # Media tools
    audacity
    ffmpeg
    sone

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
    } // firefoxWebHandlers;
  };
}
