{ ... }: {
  # Deduplicate identical files in the Nix store when adding new packages.
  nix.settings.auto-optimise-store = true;

  # Remove old profile generations, then collect unreferenced store paths.
  nix.gc = {
    automatic = true;
    dates = "Mon *-*-* 04:00:00";
    options = "--delete-older-than 30d";
    persistent = true;
    randomizedDelaySec = "30min";
  };
}
