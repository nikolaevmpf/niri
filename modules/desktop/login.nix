{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      user = "greeter";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
    };
  };
}
