{ ... }: {
  imports = [
    ./nix.nix
    ./locale.nix
    ./network.nix
    ./users.nix
    ./tools.nix
    ./opencode.nix
    ./maintenance.nix
    ./cleanup.nix
  ];
}
