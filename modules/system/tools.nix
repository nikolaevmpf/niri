{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ git nano pciutils ];
}
