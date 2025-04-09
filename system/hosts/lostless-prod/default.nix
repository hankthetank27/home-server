{
  hostName = "nixos";
  userName = "hjackson";
  userDesc = "Hank Jackson";
  system = "x86_64-linux";
  storagePath = "/mnt/storage1";
  sopsAgeKey = "/home/hjackson/.config/sops/age/keys.txt";
  hardwareConfig = import ./hardware-configuration.nix;
}
