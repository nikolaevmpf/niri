{
  description = "NixOS + Niri: nikolaev QEMU/KVM test VM";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Use the upstream dependency set; do not follow our stable nixpkgs.
    noctalia.url = "github:noctalia-dev/noctalia/40a82f21ab5f135f4324b1862f7b7732af581856";
  };
  outputs = { nixpkgs, home-manager, noctalia, ... }:
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
            home-manager.users.nikolaev = {
              imports = [ noctalia.homeModules.default ./modules/home/home.nix ];
            };
          }
        ];
      };
      checks.${system}.desktop-config = pkgs.runCommand "validate-desktop-config" {
        nativeBuildInputs = [ pkgs.niri ];
      } ''
        export HOME=$TMPDIR
        niri validate -c ${./modules/home/programs/niri/config.kdl}
        touch $out
      '';
    };
}
