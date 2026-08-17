{ pkgs, ... }:
{
  # Deliberately not added: winetricks, protonup-qt/ng as system packages —
  # Lutris vendors and runs its own winetricks from inside its FHS jail (needed
  # for GE-Proton's unpatched upstream binaries to find their dynamic linker),
  # and its built-in runner manager already fetches GE-Proton without a
  # separate tool. Use Lutris's own "Winetricks" button / runner manager
  # instead of a bare system winetricks against a GE-Proton prefix.
  #
  # If ON1's GPU-heavy AI features (denoise, etc.) turn out to need a library
  # nixpkgs' lutris doesn't already bundle, add it here, e.g.:
  #   (pkgs.lutris.override { extraLibraries = pkgs: [ pkgs.<lib> ]; })
  # Nothing is known to be missing yet — don't guess preemptively.
  environment.systemPackages = with pkgs; [ lutris ];
}
