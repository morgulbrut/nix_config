{ config, pkgs, ... }:
{
  # Assumes modules/nas/system.nix is also imported (/mnt/storage/media).
  # Used to tag ARM's "Unknown Artist" rips via MusicBrainz / AcoustID:
  #   beet import "/mnt/storage/media/music/Unknown Artist"
  environment.systemPackages = [
    pkgs.beets
    pkgs.chromaprint # fpcalc, needed by the chroma plugin
  ];

  # System-wide config; the library DB lives in /var/lib/beets so it doesn't
  # depend on any one user's home directory.
  environment.variables.BEETSDIR = "/var/lib/beets";

  systemd.tmpfiles.rules = [
    "d /var/lib/beets 0775 tillo storage -"
    "C /var/lib/beets/config.yaml 0664 tillo storage - ${pkgs.writeText "beets-config.yaml" ''
      directory: /mnt/storage/media/music-tagged
      library: /var/lib/beets/library.db
      import:
        copy: yes   # keep the original rips until you're happy with the result
        write: yes
        timid: yes  # always ask before applying a match
      plugins: chroma fetchart embedart
    ''}"
  ];
}
