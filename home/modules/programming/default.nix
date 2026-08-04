{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscode-fhs
    # vscode-extensions.golang.go
    # vscode-extensions.ms-python.python
    # vscode-extensions.platformio.platformio-vscode-ide
    # vscode-extensions.myriad-dreamin.tinymist
    # vscode-extensions.ms-python.vscode-pylance
    uv
    python3
    picocom
    neovim
  ];
}
