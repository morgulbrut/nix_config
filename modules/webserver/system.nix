{
  # Port-only virtualHost keys (":80") instead of a domain name, so Caddy
  # doesn't try to provision a Let's Encrypt cert for a host that's only
  # reachable over the LAN/tailnet. Point a real domain at erebor and switch
  # this to a domain-name key later if a site needs public HTTPS.
  services.caddy = {
    enable = true;
    virtualHosts.":80".extraConfig = ''
      root * /srv/www/default
      file_server
    '';
  };

  systemd.tmpfiles.rules = [
    "d /srv/www/default 0755 caddy caddy -"
  ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
