{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./guest.nix
    ../../modules/system
    ../../modules/desktop
  ];
  networking.hostName = "niri-vm";
  # Keep the version of the initial installation.
  system.stateVersion = "26.05";
}
