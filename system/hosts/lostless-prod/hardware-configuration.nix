# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/06931fef-d92d-4a53-aa1a-2ee870771182";
    fsType = "ext4";
  };

  fileSystems."/bin" = {
    device = "/usr/bin";
    fsType = "none";
    options = [ "bind" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EA52-3662";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  fileSystems."/mnt/storage1" = {
    device = "/dev/disk/by-uuid/881b285f-8516-40fc-94f2-9ed5e340c43b";
    fsType = "ext4";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-59aab5c39360.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-6a0bed1e0e10.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-8c84b5e93717.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-ab02fab248ba.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-af449202c15f.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-f10ac1b040c7.useDHCP = lib.mkDefault true;
  # networking.interfaces.br-f6a1ef4008ab.useDHCP = lib.mkDefault true;
  # networking.interfaces.docker0.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.tailscale0.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth1e77ef0.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth2398a11.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth3b0bb3e.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth469cc04.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth53f2486.useDHCP = lib.mkDefault true;
  # networking.interfaces.veth69c1fb5.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethb07cf60.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethd26628b.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethd3328a1.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethf6cc7f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.vethfc3d0c1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
