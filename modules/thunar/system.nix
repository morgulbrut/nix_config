{ lib, pkgs, ... }:
{
  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [ # was pkgs.xfce
    thunar-archive-plugin
    thunar-volman
  ];

  # thunar-archive-plugin only adds the "Extract Here"/"Create Archive" menu
  # entries; it delegates the actual work to an archive manager (xarchiver)
  # plus CLI tools for each format.
  environment.systemPackages = with pkgs; [
    xarchiver
    p7zip # .7z, plus zip fallback
    zip # create .zip (unzip for extraction already ships in home.nix)
    unrar # extract .rar (unfree, already allowed for this config)
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
}