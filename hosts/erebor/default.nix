{ ... }:
{
  imports = [
    ../common/base.nix
    ../../modules/nas/system.nix
    ../../modules/jellyfin/system.nix
    ../../modules/arm/system.nix
    ../../modules/tailscale/system.nix
    ../../modules/webserver/system.nix
    ../../modules/filebrowser/system.nix
    ../../modules/beets/system.nix
    ../../modules/ollama/system.nix
    # Add ../../modules/mainsail/system.nix once a printer is connected —
    # see that file for what to fill in first.
    ./hardware-configuration.nix
  ];

  networking.hostName = "erebor";

  # Pinned so it's a known literal for modules/nas + modules/arm to reference
  # (ARM_UID, file ownership) rather than whatever a fresh useradd picks.
  users.users.tillo.uid = 1000;

  # Password auth re-enabled on request (tillo's homelab key in
  # hosts/common/base.nix still works too -- this just adds password as a
  # second way in).
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # Only announce on the LAN NIC. Avahi renamed itself to erebor-2 after a
    # reload saw its own records echoed back via docker0/tailscale0.
    allowInterfaces = [ "enp11s0" ];
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
