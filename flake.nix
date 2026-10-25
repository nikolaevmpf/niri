{
  description = "Minimal modular NixOS with Niri";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/vm
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "before-niri";
            home-manager.users.nikolaev = import ./home/nikolaev;
          }
        ];
      };
      checks.${system} = {
        niri-config = pkgs.runCommand "validate-niri-config" {
          nativeBuildInputs = [ pkgs.niri ];
        } ''
          export HOME=$TMPDIR
          niri validate -c ${./home/nikolaev/niri/config.kdl}
          touch $out
        '';
      };
    };
}
