{ ... }: {
  imports = [ ./niri ./ghostty.nix ];
  home.username = "nikolaev";
  home.homeDirectory = "/home/nikolaev";
  home.stateVersion = "26.05";
  xdg.enable = true;
}
