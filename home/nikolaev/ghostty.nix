{ ... }: {
  programs.ghostty = {
    enable = true;
    installBatSyntax = false;
    systemd.enable = false;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
    };
  };
}
