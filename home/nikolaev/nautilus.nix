{ ... }: {
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications."inode/directory" = [ "org.gnome.Nautilus.desktop" ];
  };
}
