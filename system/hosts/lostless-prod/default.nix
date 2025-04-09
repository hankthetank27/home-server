{
  hostName = "nixos";
  system = "x86_64-linux";
  storagePath = "/mnt/storage1";
  hardwareConfig = import ./hardware-configuration.nix;
}
