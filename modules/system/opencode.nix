{ opencode, pkgs, ... }: {
  # Official OpenCode v2 flake, pinned in flake.nix.
  environment.systemPackages = [
    opencode.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];
}
