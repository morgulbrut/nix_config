{ config, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    autocd = true;
    defaultKeymap = "emacs";

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "${config.xdg.stateHome}/zsh/zsh_history";
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
      extended = true;
    };

    setOptions = [
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"
      "EXTENDED_GLOB"
      "INTERACTIVE_COMMENTS"
      "NO_BEEP"
    ];

    initContent = ''
      if [[ -n "$KITTY_WINDOW_ID" ]]; then
        fastfetch -c neofetch -l none | ponysay -b round
      fi
    '';
  };

  programs.starship.enable = true;

  xdg.configFile."starship.toml".source = ./gruvbox.toml;
}
