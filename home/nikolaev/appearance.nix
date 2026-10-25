{ pkgs, ... }: {
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };
  # Modern libadwaita apps (including Nautilus) use this preference.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
  gtk.enable = true;
}
