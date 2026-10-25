{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git nano pciutils
    duf mc ncdu nmap lazyssh wget curl usbutils
  ];
}
