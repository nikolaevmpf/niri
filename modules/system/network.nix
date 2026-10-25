{ ... }: {
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  services.openssh.enable = true;
}
