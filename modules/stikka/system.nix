{ config, lib, ... }:
let
  # Public at https://stikka.party through a Cloudflare Tunnel. Cloudflare
  # terminates TLS and cloudflared dials out to it, so nothing is opened in
  # the firewall and erebor's Caddy isn't involved: cloudflared hands
  # requests (WebSockets included) straight to the app on loopback.
  domain = "stikka.party";
  appPort = 3100;

  # ID of the tunnel made with `cloudflared tunnel create stikka` (printed
  # there, and the name of the JSON file it writes). Not secret. Leave null
  # until the tunnel exists: the app then still runs, just without the
  # tunnel, at http://127.0.0.1:3100 on erebor.
  tunnelId = null;

  stateDir = "/var/lib/stikka";

  # Created by hand on erebor, never in this repo (see the steps in
  # stikka-server's thread):
  #   postgres.env  POSTGRES_PASSWORD=...
  #   app.env       DATABASE_URL=postgres://stikka:<same password>@stikka-postgres:5432/stikka
  #                 ADMIN_TOKEN=...
  secretsDir = "${stateDir}/secrets";
in
{
  # The stack from stikka-factory/stikka-server's docker-compose.yml, minus
  # its Caddy, on base.nix's Docker daemon.
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers = {
    stikka-postgres = {
      image = "postgres:17-alpine";
      autoStart = true;
      networks = [ "stikka" ];
      environment = {
        POSTGRES_USER = "stikka";
        POSTGRES_DB = "stikka";
      };
      environmentFiles = [ "${secretsDir}/postgres.env" ];
      volumes = [ "${stateDir}/postgres:/var/lib/postgresql/data" ];
    };

    stikka-app = {
      # Image pulls only when missing. To update:
      #   docker pull ghcr.io/stikka-factory/stikka-server:latest
      #   sudo systemctl restart docker-stikka-app
      image = "ghcr.io/stikka-factory/stikka-server:latest";
      autoStart = true;
      dependsOn = [ "stikka-postgres" ];
      networks = [ "stikka" ];
      ports = [ "127.0.0.1:${toString appPort}:3000" ];
      environment = {
        PUBLIC_URL = "https://${domain}";
        DATA_DIR = "/data";
        GEO_PROVIDER = "beacondb";
      };
      environmentFiles = [ "${secretsDir}/app.env" ];
      volumes = [ "${stateDir}/data:/data" ];
    };
  };

  # Shared network so the app reaches Postgres by container name, like
  # compose's default network. Postgres publishes no port.
  systemd.services.docker-network-stikka = {
    description = "Docker network for the Stikka stack";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    before = [
      "docker-stikka-postgres.service"
      "docker-stikka-app.service"
    ];
    requiredBy = [
      "docker-stikka-postgres.service"
      "docker-stikka-app.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${config.virtualisation.docker.package}/bin/docker network inspect stikka >/dev/null 2>&1 \
        || ${config.virtualisation.docker.package}/bin/docker network create stikka
    '';
  };

  # The postgres image chowns its own data dir on start; the app runs as the
  # image's `node` user (uid 1000) and writes uploaded fonts to /data.
  systemd.tmpfiles.rules = [
    "d ${stateDir} 0755 root root -"
    "d ${secretsDir} 0700 root root -"
    "d ${stateDir}/postgres 0700 root root -"
    "d ${stateDir}/data 0750 1000 1000 -"
  ];

  services.cloudflared = lib.mkIf (tunnelId != null) {
    enable = true;
    tunnels.${tunnelId} = {
      credentialsFile = "${secretsDir}/cloudflared.json";
      ingress.${domain} = "http://127.0.0.1:${toString appPort}";
      default = "http_status:404";
    };
  };
}
