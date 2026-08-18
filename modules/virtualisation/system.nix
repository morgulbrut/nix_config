{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      # swtpm provides the emulated TPM 2.0 that Windows 11 setup requires.
      # Secure Boot-capable OVMF firmware ships with qemu by default.
      swtpm.enable = true;
    };
  };

  # Lets USB devices be redirected into the VM from virt-manager/virt-viewer.
  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  users.users.tillo.extraGroups = [ "libvirtd" ];
}
