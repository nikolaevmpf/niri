{ pkgs, ... }: {
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "nix-update";
      runtimeInputs = with pkgs; [ git nix nixos-rebuild ];
      text = builtins.readFile ./nix-update.sh;
    })
    (pkgs.writeShellApplication {
      name = "nix-rollback";
      runtimeInputs = [ pkgs.nixos-rebuild ];
      text = ''
        exec sudo nixos-rebuild switch --rollback
      '';
    })
  ];
}
