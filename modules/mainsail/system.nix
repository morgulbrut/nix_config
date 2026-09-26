{ pkgs, ... }:
{
  # Stub — NOT imported by hosts/erebor/default.nix yet. There's no printer
  # connected. To activate once one is:
  #   1. Plug in the printer, find its stable device path:
  #        ls -l /dev/serial/by-id/
  #   2. Replace the CHANGEME serial (and kinematics/limits) below to match
  #      the printer.
  #   3. Add "../../modules/mainsail/system.nix" to hosts/erebor/default.nix's
  #      imports.
  #   4. Rebuild, then open http://erebor:8080.
  # Double check the reverse-proxy paths below against Mainsail's current
  # nginx.conf template (github.com/mainsail-crew/mainsail) before relying on
  # this — it may have grown new routes since this was written.

  services.klipper = {
    enable = true;
    settings = {
      printer = {
        serial = "/dev/serial/by-id/CHANGEME-printer";
        baud = 250000;
        kinematics = "cartesian"; # CHANGEME to match the printer
        max_velocity = 300;
        max_accel = 3000;
        max_z_velocity = 5;
        max_z_accel = 100;
      };
    };
  };

  services.moonraker = {
    enable = true;
    settings = {
      authorization = {
        # Tailscale CGNAT range + typical private LAN ranges.
        trusted_clients = [
          "100.64.0.0/10"
          "192.168.0.0/16"
          "10.0.0.0/8"
        ];
      };
    };
  };

  services.caddy.virtualHosts.":8080".extraConfig = ''
    root * ${pkgs.mainsail}
    file_server
    reverse_proxy /websocket 127.0.0.1:7125
    reverse_proxy /server/* 127.0.0.1:7125
    reverse_proxy /printer/* 127.0.0.1:7125
    reverse_proxy /api/* 127.0.0.1:7125
    reverse_proxy /access/* 127.0.0.1:7125
    reverse_proxy /machine/* 127.0.0.1:7125
  '';
}
