{ ... }:
{
  fileSystems."/home/tillo/Data" = {
    device = "/dev/disk/by-uuid/0476B1AC76B19EBC";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "gid=100" "nofail" ];
  };

  # fileSystems."/mnt/old-efi" = {
  #   device = "/dev/disk/by-uuid/06DA-24A4";
  #   fsType = "vfat";
  #   options = [ "nofail" ];
  # };

  # # Auto-unlock old-root at boot (no passphrase prompt) via a keyfile embedded
  # # in the initrd. Generate and register the keyfile once, before rebuilding:
  # #   sudo mkdir -p /etc/luks-keys
  # #   sudo dd if=/dev/urandom of=/etc/luks-keys/old-root.key bs=512 count=4
  # #   sudo chmod 600 /etc/luks-keys/old-root.key
  # #   sudo cryptsetup luksAddKey /dev/sdb2 /etc/luks-keys/old-root.key   # prompts for the existing passphrase
  # boot.initrd.luks.devices."old-root" = {
  #   device = "/dev/disk/by-uuid/328fd040-c299-4fad-aa4c-93099da6cb02";
  #   keyFile = "/etc/luks-keys/old-root.key";
  # };

  # boot.initrd.secrets = {
  #   "/etc/luks-keys/old-root.key" = "/etc/luks-keys/old-root.key";
  # };

  # fileSystems."/mnt/old-root" = {
  #   device = "/dev/mapper/old-root";
  #   fsType = "ext4"; # verify with `lsblk -f /dev/mapper/old-root` after luksOpen — correct if wrong
  #   options = [ "nofail" ];
  # };
}
