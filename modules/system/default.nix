{ ... }: {
  imports = [
    ./nix.nix
    ./locale.nix
    ./network.nix
    ./users.nix
    ./tools.nix
    ./maintenance.nix
    ./cleanup.nix
  ];
}
