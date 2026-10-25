{ pkgs, ... }: {
  programs.niri = {
    enable = true;
    # Use the GTK file chooser; do not install a file manager yet.
    useNautilus = false;
  };
  hardware.graphics.enable = true;
  # Niri's NixOS module configures Wayland, D-Bus and desktop portals.
  security.polkit.enable = true;
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  systemd.user.services.polkit-agent = {
    description = "Polkit authentication agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
