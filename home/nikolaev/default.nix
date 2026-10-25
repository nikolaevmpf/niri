{ ... }: {
  imports = [ ./niri ./ghostty.nix ./appearance.nix ./nautilus.nix ];
  home.username = "nikolaev";
  home.homeDirectory = "/home/nikolaev";
  home.stateVersion = "26.05";
  xdg.enable = true;
}
