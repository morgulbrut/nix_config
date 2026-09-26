{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Trust the tailnet fully so NAS shares, Jellyfin, the web server, etc. are
  # reachable from anywhere without opening each service to the public/LAN
  # interfaces individually.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
