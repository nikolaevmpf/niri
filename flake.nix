{
  description = "Minimal modular NixOS with Niri";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # OpenCode v2.2.0; keep its own upstream build dependencies.
    opencode.url = "github:anomalyco/opencode/1097e2668b1e08ad63bdf0b1c4860b9bc01e420c";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, opencode, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit opencode; };
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
