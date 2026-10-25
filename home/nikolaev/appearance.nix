{ pkgs, ... }:
let
  catppuccinTheme = {
    name = "catppuccin-mocha-blue-standard";
    package = pkgs.catppuccin-gtk.override {
      variant = "mocha";
      accents = [ "blue" ];
      size = "standard";
      tweaks = [];
    };
  };
in {
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = catppuccinTheme;
    # Home Manager imports the theme CSS for GTK4/libadwaita apps.
    gtk4.theme = catppuccinTheme;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
