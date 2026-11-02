{ appimageTools, fetchurl }:
let
  pname = "photocraft";
  version = "0.9.0";
  src = fetchurl {
    url = "https://github.com/storytold/photocraft/releases/download/v${version}/photocraft-${version}-linux-x86_64.AppImage";
    sha256 = "483a9a79200e0c0864bb54cf3faa6a55e2b79c1433dacfcb153d3862e78f32bc";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    install -Dm444 ${contents}/*.desktop -t $out/share/applications || true
  '';
}
