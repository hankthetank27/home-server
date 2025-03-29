{ pkgs, config, ... }:
let
  composeFile = pkgs.writeTextFile {
    name = "compose.yml";
    text =
      #yaml
      ''
        services:
          navidrome:
            image: deluan/navidrome:latest
            container_name: navidrome
            restart: always
            environment:
              - ND_MUSICFOLDER=/music
              - ND_DATAFOLDER=/data
            volumes:
              - /mnt/storage1/navidrome-fileshare-app/music:/music
              - /mnt/storage1/navidrome-fileshare-app/navidrome-data:/data
            networks:
              - web
            ports:
              - 4533:4533
          filebrowser:
            image: filebrowser/filebrowser:latest
            container_name: filebrowser
            restart: always
            user: 1000:1000
            volumes:
              - /mnt/storage1/navidrome-fileshare-app/music:/srv
              - /mnt/storage1/navidrome-fileshare-app/filebrowser-config/database.db:/database.db
            networks:
              - web
            ports:
              - 8081:80
          cloudflared-tunnel:
             image: cloudflare/cloudflared:latest
             container_name: cloudflared-tunnel
             restart: unless-stopped
             environment:
              - TUNNEL_TOKEN=''${TUNNEL_TOKEN}
             command: tunnel run
             networks:
               - web
             depends_on:
               - navidrome
               - filebrowser
        networks:
          web:
            external: false
      '';
  };
in
{
  sops.secrets.navidrome-cloudflare-tunnel-token = {
    owner = "hjackson";
  };

  systemd.services.navidrome-fileshare-app = {
    requires = [
      "docker.service"
      "network-online.target"
    ];
    after = [
      "docker.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ENV_FILE_TMP=/tmp/cloudflared-tunnel
      echo -n "TUNNEL_TOKEN=" > $ENV_FILE_TMP && cat ${config.sops.secrets.navidrome-cloudflare-tunnel-token.path} | tr -d '\n' >> $ENV_FILE_TMP
      ${pkgs.docker}/bin/docker compose --env-file $ENV_FILE_TMP -f ${composeFile} up -d;
    '';
    serviceConfig = {
      User = "hjackson";
      Type = "oneshot";
      RemainAfterExit = true;

      # WorkingDirectory = "/etc/nixos/services/navidrome-fileshare-app";
      # ExecStartPre = [ "${pkgs.docker}/bin/docker compose down --remove-orphans" ];
      # ExecStart = "${pkgs.docker}/bin/docker compose up -d";
      # ExecStop = "${pkgs.docker}/bin/docker compose down --remove-orphans";

      ExecStartPre = [ "${pkgs.docker}/bin/docker compose -f ${composeFile} down --remove-orphans" ];
      # ExecStart = "${pkgs.docker}/bin/docker compose -f ${composeFile} up -d";
      ExecStop = "${pkgs.docker}/bin/docker compose -f ${composeFile} down --remove-orphans";

      Restart = "on-failure";
    };
  };
}
