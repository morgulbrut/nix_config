{ lib, ... }:
{
  # Web UI for uploading/browsing files from any device on the LAN/tailnet
  # (phone, tablet, guest laptop) without installing anything client-side.
  # Listens directly on its own port -- http://erebor.local:8080/ -- rather
  # than sharing :80, which is the static services directory
  # (modules/webserver/system.nix).
  #
  # Runs as tillo:storage rather than a dedicated system account, and its
  # root is /mnt/storage itself -- the same tree the NFS/Samba shares
  # expose and ARM/Jellyfin already read and write, so uploads show up
  # everywhere immediately instead of living in their own separate folder.
  # This mirrors how ARM (modules/arm/system.nix) and the NFS export
  # (modules/nas/system.nix) already act as tillo:storage rather than their
  # own identities -- one consistent owner across every way into the pool.
  services.filebrowser = {
    enable = true;
    openFirewall = true;
    user = "tillo";
    group = "storage";
    settings = {
      address = "0.0.0.0";
      port = 8080;
      root = "/mnt/storage";
    };
  };

  # The module hard-codes its root directory to mode 0700 via
  # systemd.tmpfiles on every boot (fine for a private, single-owner
  # directory; wrong here since /mnt/storage is shared). Override just the
  # mode so this agrees with modules/nas/system.nix's own rule for the same
  # path (2775 tillo storage) instead of fighting it.
  systemd.tmpfiles.settings.filebrowser."/mnt/storage".d.mode = lib.mkForce "2775";

  systemd.services.filebrowser.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];
}
