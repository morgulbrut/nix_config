{ config, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home.username = "tillo";
  home.homeDirectory = "/home/tillo";
  home.stateVersion = "26.05";

  imports = [
    ../../modules/shell/home.nix
    ../../modules/zsh/home.nix
  ];

  xdg.enable = true;

  # ensure ~/.nix-profile points at the managed Home Manager profile so packages resolve
  home.file.".nix-profile" = {
    source = config.home.path;
    force = true;
  };
}
