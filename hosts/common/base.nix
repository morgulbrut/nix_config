{ config, inputs, pkgs, ... }:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };
in
{
  imports = [
    ./optimisations.nix
  ];

  # -------- basics --------
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_GB.UTF-8";
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = false;

  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  nixpkgs.overlays = [
    (final: prev: {
      atopile = prev.writeShellScriptBin "atopile" ''
        echo "Atopile placeholder; real package not available on this channel."
      '';
    })
  ];

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
    daemon.settings = {
      dns = [ "1.1.1.1" "8.8.8.8" ];
      features = {
        buildkit = true;
      };
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "exfat" "ntfs3" ];

  services.printing.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.hardware.bolt.enable = true;

  # Keep bash as the login/recovery shell; interactive bash hands off to zsh.
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  users.users.tillo = {
    isNormalUser = true;
    description = "tillo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "docker"
    ];
    shell = pkgs.bashInteractive;
    # Dedicated key for logging into hosts (separate from the GitHub key);
    # lets any host with sshd enabled accept tillo without a password.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINz18tVI691J9FhrmnnyKvfiM07UjlY3u13zH5EFFlJO tillo@homelab"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7cMNi5fRF6x3j1LDdD0axPeReYeZCWowEkb2A4QY4A tillo@Tillos-MacBook-Pro.local"
    ];
  };

  # Program toggles
  # programs.bazecor = {
  #   enable = true;
  #   package = pkgsUnstable.bazecor;
  # };
  programs.bash.interactiveShellInit = ''
    # Launch zsh for normal interactive shells, while keeping bash in /etc/passwd.
    if [[ $UID -eq 1000 && $SHLVL == [12] ]]; then
      read -r parent < /proc/$PPID/comm || parent=
      if [[ $parent != zsh ]]; then
        SHELL=${pkgs.zsh}/bin/zsh exec ${pkgs.zsh}/bin/zsh
      fi
    fi
  '';
  programs.zsh.enable = true; # expose zsh system-wide without making it the login shell

  # The Defy exposes a CDC ACM serial interface for Bazecor. Keep modem probing
  # away from it so Bazecor can own the protocol handshake reliably.
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="35ef", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;

    # Only local admins should be able to submit builds to the daemon.
    allowed-users = [ "@wheel" ];
  };

  environment.systemPackages = with pkgs; [
    exfatprogs
    smartmontools
    usbutils
    wireguard-tools
    # SSHing in from a Kitty terminal sends TERM=xterm-kitty; without this,
    # a host has no matching terminfo entry and zsh's line editor
    # miscalculates cursor position on every keystroke, which looks like
    # keystrokes doubling as you type.
    kitty.terminfo
  ];

  system.stateVersion = "26.05";
}
