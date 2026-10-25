{ pkgs, ... }: {
  imports = [ ./programs/wofi.nix ./programs/ghostty.nix ];
  home.username = "nikolaev";
  home.homeDirectory = "/home/nikolaev";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [ waybar swaylock swaynotificationcenter ];
  programs.bash.enable = true;
  xdg.enable = true;
  xdg.userDirs = { enable = true; createDirectories = true; };
  xdg.configFile."niri/config.kdl".source = ./programs/niri/config.kdl;
  xdg.configFile."waybar/config".source = ./programs/waybar/waybar.conf;
  xdg.configFile."waybar/style.css".source = ./programs/waybar/waybar.css;
  gtk = {
    enable = true;
    theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
