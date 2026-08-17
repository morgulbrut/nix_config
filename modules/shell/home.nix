{ ... }:
{
  home.shellAliases = {
    ls = "eza --group-directories-first --icons";
    ll = "ls -lh";
    la = "ls -lAh";
    grep = "rg";
    ripgrep = "rg";
    vi = "vim";
    vim = "nvim";
    tree = "erd -H -y inverted";
    tl = "tree -l";
    td = "tree --dirs-only -l";
    ".." = "cd ..";
    "..." = "cd ../..";
    rebnix = "cd ~/nix_config && sudo nixos-rebuild switch --flake .";
    cleanix = "nix-collect-garbage && rebnix && nixos-rebuild list-generations";
  };
}
