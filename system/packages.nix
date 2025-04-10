{ pkgs }:
with pkgs;
[
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
]
