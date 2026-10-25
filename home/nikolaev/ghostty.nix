{ ... }: {
  programs.ghostty = {
    enable = true;
    installBatSyntax = false;
    systemd.enable = false;
    settings = {
      window-decoration = "none";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
    };
  };
}
