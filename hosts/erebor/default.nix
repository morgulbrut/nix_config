{ ... }:
{
  imports = [
    ../common/base.nix
    ../../modules/nas/system.nix
    ../../modules/jellyfin/system.nix
    ../../modules/arm/system.nix
    ../../modules/tailscale/system.nix
    ../../modules/webserver/system.nix
    # Add ../../modules/mainsail/system.nix once a printer is connected —
    # see that file for what to fill in first.
    ./hardware-configuration.nix
  ];

  networking.hostName = "erebor";

  # Pinned so it's a known literal for modules/nas + modules/arm to reference
  # (ARM_UID, file ownership) rather than whatever a fresh useradd picks.
  users.users.tillo.uid = 1000;

  # Headless box — password auth for now so it's reachable right after the
  # first boot; switch to key-only once a key is set up.
  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
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
