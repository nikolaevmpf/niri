# Noctalia v5; its upstream Home Manager module is imported in flake.nix.
{ ... }: {
  programs.noctalia = {
    enable = true;
    # Started by Niri, not by a second systemd service.
    systemd.enable = false;
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };
      # Keep the existing, separately configured swaylock for this VM.
      lockscreen.enabled = false;
      # Keep the existing GNOME polkit agent; avoid registering two agents.
      shell.polkit_agent = false;
    };
  };
}
