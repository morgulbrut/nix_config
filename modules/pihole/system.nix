{
  # Pi-hole running in Docker. Before the first deploy, run scripts/setup-pihole.sh as root.
  # After deploy, point LAN clients at erebor's IP as their DNS server.
  virtualisation.oci-containers = {
    backend = "docker";
    containers.pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "8053:80/tcp"
      ];
      volumes = [
        "/var/lib/pihole/etc-pihole:/etc/pihole"
        "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
      ];
      environment = {
        TZ = "Europe/Zurich";
        PIHOLE_DNS_ = "1.1.1.1;8.8.8.8";
      };
      # FTLCONF_webserver_api_password lives here to stay out of the Nix store.
      environmentFiles = [ "/var/secrets/pihole.env" ];
    };
  };

  # systemd-resolved's stub listener is on 127.0.0.53:53 (not 0.0.0.0:53), so
  # it doesn't conflict with Pi-hole's host port binding.
  networking.firewall = {
    allowedTCPPorts = [ 53 8053 ];
    allowedUDPPorts = [ 53 ];
  };

  # Persist blocklists and settings across container restarts.
  systemd.tmpfiles.rules = [
    "d /var/lib/pihole/etc-pihole 0755 root root -"
    "d /var/lib/pihole/etc-dnsmasq.d 0755 root root -"
  ];
}
