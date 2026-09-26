# Placeholder hardware config so the flake evaluates before erebor exists.
#
# Once NixOS is installed on the real hardware, replace this whole file with
# the output of running (on erebor itself, from the installer or a booted
# system):
#   sudo nixos-generate-config --root /mnt --show-hardware-config > hardware-configuration.nix
# (or just `sudo nixos-generate-config` and copy /etc/nixos/hardware-configuration.nix)
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # CHANGEME: real UUIDs come from the generated hardware-configuration.nix.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/CHANGEME-root-uuid";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CHANGEME-boot-uuid";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
