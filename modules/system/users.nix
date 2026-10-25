{ ... }: {
  # Existing password is preserved; no credentials are stored in Git.
  users.mutableUsers = true;
  users.users.nikolaev = {
    isNormalUser = true;
    description = "Nikolaev Alexander";
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
