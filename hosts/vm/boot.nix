{ pkgs, ... }: {
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  # Preserve the kernel choice from the installed VM.
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
