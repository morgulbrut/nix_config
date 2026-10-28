{ config, ... }:
{
  # GitLab CE. Before the first deploy, run scripts/setup-gitlab.sh as root.
  # NixOS manages PostgreSQL and Redis internally -- no separate setup needed.
  services.gitlab = {
    enable = true;
    https = false;
    host = "erebor.local";
    port = 8929;
    initialRootPasswordFile = "/var/secrets/gitlab/root-password";
    databasePasswordFile = "/var/secrets/gitlab/db-password";
    secrets = {
      secretFile = "/var/secrets/gitlab/secret";
      otpFile = "/var/secrets/gitlab/otp-secret";
      dbFile = "/var/secrets/gitlab/db-secret";
      jwsFile = "/var/secrets/gitlab/jws-key";
      activeRecordPrimaryKeyFile = "/var/secrets/gitlab/ar-primary-key";
      activeRecordDeterministicKeyFile = "/var/secrets/gitlab/ar-deterministic-key";
      activeRecordSaltFile = "/var/secrets/gitlab/ar-salt";
    };
    smtp.enable = false;
  };

  # Caddy proxies to the GitLab Workhorse Unix socket on a dedicated port.
  # caddy needs the gitlab group to read the socket.
  users.users.caddy.extraGroups = [ "gitlab" ];

  services.caddy.virtualHosts.":8929".extraConfig = ''
    reverse_proxy unix/${config.services.gitlab.statePath}/tmp/sockets/gitlab-workhorse.socket
  '';

  networking.firewall.allowedTCPPorts = [ 8929 ];
}
