{ pkgs, ... }:
{
  # Lutris (Wine/Proton game & app manager) — used here to run ON1 Photo RAW,
  # a Windows-only RAW editor with no native Linux build or Flatpak.
  #
  # pkgs.lutris is a buildFHSEnv wrapper (nixpkgs pkgs/by-name/lu/lutris/package.nix)
  # that already bundles everything Wine/Proton need on NixOS: 32-bit Vulkan/
  # X11/gstreamer/Qt libs, p7zip, cabextract, samba4, gcc, opencl-headers, etc.
  # It solves the usual NixOS "wine expects /lib64/ld-linux..." problem on its
  # own, so no extra FHS/steam-run shim is needed here.
  #
  # GE-Proton builds (e.g. GE-Proton10-34, documented to work for ON1 Photo RAW)
  # are not nix-packaged and never will be — Lutris's own runner manager
  # (Preferences > Manage Runners, or the Wine-version dropdown on a game's
  # config page) fetches them straight into ~/.local/share/lutris/runners/wine,
  # outside the nix store. That's expected, not a gap to fill.
  #
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
