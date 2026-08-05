{ pkgs, ... }:
{
  # Root-privileged SMART collector for noctalia's gustav0ar/drive-health
  # plugin. The plugin ships its own installer (install-system-collector.sh)
  # that writes a systemd unit into /etc/systemd/system, but NixOS's /etc is
  # read-only, so that installer can't run here. This reproduces the same
  # service + timer declaratively, running the vendored ./collect_raw.sh
  # (see that file's header) instead of the plugin's live, auto-updating copy.
  #
  # Enable the plugin's "system_collector_enabled" setting (see
  # home/modules/niri/noctalia/default.nix) so the plugin actually reads
  # /run/noctalia-drive-health/raw.json instead of shelling out to smartctl
  # itself. The plugin's own pause/resume and "change interval" UI actions
  # won't work (they pkexec into /usr/local/libexec, which isn't populated
  # here) — adjust timerConfig below instead.

  systemd.services.noctalia-drive-health = {
    description = "Collect read-only SMART data for Noctalia Drive Health";
    documentation = [ "man:smartctl(8)" ];
    after = [ "local-fs.target" ];
    path = [ pkgs.smartmontools pkgs.util-linux ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.runtimeShell} ${./collect_raw.sh} --output /run/noctalia-drive-health/raw.json";
      Group = "users";
      RuntimeDirectory = "noctalia-drive-health";
      RuntimeDirectoryMode = "0750";
      RuntimeDirectoryPreserve = "yes";
      UMask = "0027";
      StandardOutput = "null";
      StandardError = "journal";
      TimeoutStartSec = "60s";
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateNetwork = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" "CAP_SYS_ADMIN" "CAP_SYS_RAWIO" ];
      ReadWritePaths = [ "/run/noctalia-drive-health" ];
    };
  };

  systemd.timers.noctalia-drive-health = {
    description = "Refresh SMART data for Noctalia";
    timerConfig = {
      OnBootSec = "20s";
      OnUnitActiveSec = "15min";
      AccuracySec = "5s";
    };
    wantedBy = [ "timers.target" ];
  };
}
