{
  # Port-only virtualHost keys (":80") instead of a domain name, so Caddy
  # doesn't try to provision a Let's Encrypt cert for a host that's only
  # reachable over the LAN/tailnet. Point a real domain at erebor and switch
  # this to a domain-name key later if a site needs public HTTPS.
  #
  # erebor's front door is FileBrowser (modules/filebrowser/system.nix) --
  # http://erebor/ reverse-proxies straight to it.
  services.caddy = {
    enable = true;
    virtualHosts.":80".extraConfig = ''
      reverse_proxy 127.0.0.1:8080
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
