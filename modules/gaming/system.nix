{ config, inputs, ... }:
{
  # Steam ships 32-bit binaries; base.nix only enables the 64-bit graphics stack.
  hardware.graphics.enable32Bit = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
}
