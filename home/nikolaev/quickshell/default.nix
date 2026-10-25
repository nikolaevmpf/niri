{ config, pkgs, ... }: {
  home.packages = [ pkgs.quickshell ];
  xdg.configFile."quickshell/niri".source = ./config;

  # One managed instance, started and stopped with the graphical session.
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Niri desktop panel (Quickshell)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      X-Restart-Triggers = [
        "${config.xdg.configFile."quickshell/niri".source}"
      ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell -c niri";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
