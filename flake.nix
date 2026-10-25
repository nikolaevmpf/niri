{
  description = "NixOS + Niri: nikolaev QEMU/KVM test VM";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations.niri-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "before-niri";
            home-manager.users.nikolaev = import ./modules/home/home.nix;
          }
        ];
      };
      checks.${system}.desktop-config = pkgs.runCommand "validate-desktop-config" {
        nativeBuildInputs = [ pkgs.niri pkgs.python3 ];
      } ''
        export HOME=$TMPDIR
        niri validate -c ${./modules/home/programs/niri/config.kdl}
        python -m json.tool ${./modules/home/programs/waybar/waybar.conf} > /dev/null
        touch $out
      '';
    };
}
