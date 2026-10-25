{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "niri-vm";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = { font = "cyr-sun16"; keyMap = "ru"; };
  services.xserver.xkb = { layout = "us,ru"; options = "grp:alt_shift_toggle"; };

  users.users.nikolaev = {
    isNormalUser = true;
    description = "Nikolaev Alexander";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git curl wget nano pciutils btop fastfetch
    firefox nautilus pavucontrol wl-clipboard playerctl
    xwayland-satellite polkit_gnome adwaita-icon-theme
  ];
  hardware.graphics.enable = true;
  programs.niri.enable = true;
  programs.dconf.enable = true;
  services.displayManager.ly.enable = true;
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.openssh.enable = true;
  services.gvfs.enable = true;
  services.upower.enable = true;
  # Official upstream binary cache for the separately pinned Noctalia package.
  nix.settings.extra-substituters = [ "https://noctalia.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono noto-fonts noto-fonts-color-emoji ];
  system.stateVersion = "26.05";
}
