{ pkgs, ... }:
{
  # Display manager (SDDM) + X11 stack for the greeter
  services.xserver.enable = true;
  services.xserver.xkb = { layout = "us"; variant = "altgr-intl"; };
  services.displayManager.sddm = {
    enable = true;
    settings = {
      General = {
        InputMethod = "";
      };
    };
  };
  services.displayManager.defaultSession = "niri";
  console.useXkbConfig = true;

  services.gvfs.enable = true;

  programs.dconf.enable = true;
  programs.xwayland.enable = true;
  programs.niri.enable = true; # Niri session in the display manager

  # Graphics (25.11 uses hardware.graphics.*)
  hardware.graphics = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    # Use niri's recommended portal preference order (niri-portals.conf).
    configPackages = [ pkgs.niri ];
  };

  # Needed for the Secret portal (Flatpak apps) and recommended by niri docs.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.symbols-only
    nerd-fonts.bigblue-terminal
    nerd-fonts.heavy-data
    nerd-fonts.hurmit
    roboto
  ];

  environment.systemPackages = with pkgs; [
    xwayland-satellite

    # GTK theming, used globally (not just by Thunar)
    papirus-icon-theme
    adw-gtk3
    bibata-cursors
  ];
}
