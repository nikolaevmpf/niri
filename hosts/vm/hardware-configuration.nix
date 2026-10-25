# VM hardware supplied by nikolaev. Replace with the local generated file if needed.
{ lib, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.initrd.availableKernelModules = [
    "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/59e6786c-801d-40d4-beb3-2e763e6dfc07";
    fsType = "btrfs";
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/59e6786c-801d-40d4-beb3-2e763e6dfc07";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/59e6786c-801d-40d4-beb3-2e763e6dfc07";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/DCA9-05A5";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  swapDevices = [];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
