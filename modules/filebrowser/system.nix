{ ... }:
{
  # Web UI for uploading/browsing files from any device on the LAN/tailnet
  # (phone, tablet, guest laptop) without installing anything client-side.
  # Reverse proxied by Caddy (modules/webserver/system.nix) at
  # http://erebor/.
  #
  # Runs as FileBrowser's own dedicated, unprivileged system user in its own
  # subtree of the NAS pool -- not the same tree Samba/NFS expose. The
  # NixOS module hard-codes that directory to mode 0700 (re-applied via
  # systemd.tmpfiles on every boot), so pointing it at /mnt/storage itself
  # would lock Samba/NFS out of the whole pool. Move files between the two
  # through the FileBrowser UI itself.
  services.filebrowser = {
    enable = true;
    settings = {
      address = "127.0.0.1";
      port = 8080;
      root = "/mnt/storage/filebrowser";
    };
  };

  systemd.services.filebrowser.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];
}
