{ pkgs, ... }:
let
  # KiCad's scripting console/action plugins run on a bundled Python whose
  # PYTHONPATH is set explicitly by the wrapper (it ignores the ambient
  # PYTHONPATH), so `pip` has to be added to KiCad's own pythonPath to be
  # importable from inside KiCad itself.
  kicadWithAddons = pkgs.kicad.override {
    addons = with pkgs.kicadAddons; [
      kikit
      kikit-library
    ];
  };

  kicadPkg = kicadWithAddons.overrideAttrs (old: {
    pythonPath = (old.pythonPath or [ ]) ++ [ pkgs.python3.pkgs.pip ];
  });
in
{
  home.packages = [ kicadPkg ];
}
