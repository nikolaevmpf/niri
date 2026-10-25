{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.nautilus ];
  # File chooser integration with Niri's GNOME portal.
  programs.niri.useNautilus = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
