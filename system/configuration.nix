{
  pkgs,
  inputs,
  storagePath,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./home
    ../services
    inputs.sops-nix.nixosModules.sops
  ];

  # Prevent system from sleeping on inactivity
  services.logind = {
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      IdleAction=ignore
      IdleActionSec=0
    '';
  };

  powerManagement.enable = false;

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  fileSystems.${storagePath} = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/hjackson/.config/sops/age/keys.txt";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.ethernet.macAddress = "preserve";

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hjackson = {
    isNormalUser = true;
    description = "Hank Jackson";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;

  # Enable !#/bin/bash
  services.envfs.enable = true;

  environment.systemPackages = with pkgs; [
    docker
    htop
    vim
    git
    wget
    coreutils
    ffmpeg
    ripgrep
    jq
    wget
    curl
    unzip
    unrar
    xz
    sops
    cloudflared
    tailscale
    (beets.override {
      pluginOverrides = {
        beatport.enable = true;
        discogs.enable = true;
      };
    })
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.firewall.allowedTCPPorts = [
    80
    433
    22
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (b).
  system.stateVersion = "24.11"; # Did you read the comment?

}
