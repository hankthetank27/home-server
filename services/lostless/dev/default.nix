{
  type,
  filebrowserSha,
  withCloudflared,
  pkgs,
  ...
}:
let
  utils = import ../../../utils/default.nix { inherit pkgs; };
in
rec {
  filebrowserDockerfile = pkgs.dockerTools.buildImage {
    name = "filebrowser-custom-${type}";
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
      # using my fork for the time being with bug fix for ignoring "Upload" hook.
      imageName = "hjackson277/filebrowser";
      imageDigest = "sha256:4530adc1e8188716393d839e61d2db6445ec60bf50d3b75d12ead070b28e99b1";
      sha256 = filebrowserSha;
      finalImageName = "hjackson277/filebrowser-${type}";
      finalImageTag = "v1.0.0";
    };
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [
        pkgs.bash
        pkgs.ffmpeg
      ] ++ utils.makeScriptsFromDir ./bin;
      pathsToLink = [ "/bin" ];
    };
    config = {
      Cmd = [
        "/filebrowser"
        "-d"
        "/filebrowser.db"
      ];
    };
  };

  cloudflared =
    # extra indent needed below for correct string formatting
    # yaml
    ''
      cloudflared-tunnel:
          image: cloudflare/cloudflared:latest
          container_name: cloudflared-tunnel-${type}
          restart: unless-stopped
          environment:
           - TUNNEL_TOKEN=''${TUNNEL_TOKEN}
          command: tunnel run
          networks:
            - web-${type}
          depends_on:
           - navidrome
           - filebrowser
           - invite-service
    '';

  mkComposeFile =
    appStorage:
    pkgs.writeTextFile {
      name = "lostless-compose-${type}.yml";
      text =
        #yaml
        ''
          services:
            ${if withCloudflared then cloudflared else ""}
            navidrome:
              image: deluan/navidrome:latest
              container_name: navidrome-${type}
              restart: always
              environment:
                - ND_MUSICFOLDER=/music
                - ND_DATAFOLDER=/data
                - ND_UIWELCOMEMESSAGE=welcome..
                - ND_UILOGINBACKGROUNDURL=https://i.postimg.cc/ncxpBsSF/linux-bg.jpg
                - ND_DEFAULTTHEME=Nuclear
              volumes:
                - ${appStorage}/music:/music
                - ${appStorage}/navidrome-data:/data
              networks:
                - web-${type}
              ports:
                - ${if type == "prod" then "4533" else "4534"}:4533
            filebrowser:
              image: filebrowser-custom-${type}
              container_name: filebrowser-${type}
              restart: always
              user: 1000:1000
              volumes:
                - ${appStorage}/music:/srv
                - ${appStorage}/filebrowser-config/database.db:/filebrowser.db
              environment:
               - DISCORD_WEBHOOK=''${DISCORD_WEBHOOK}
              networks:
                - web-${type}
              ports:
                - ${if type == "prod" then "8081" else "8082"}:80
            invite-service:
              image: invite-service
              container_name: invite-service-${type}
              restart: unless-stopped
              environment:
                - APP_URL=''${APP_URL}
                - FILEBROWSER_HOST=''${FILEBROWSER_HOST}
                - NAVIDROME_HOST=''${NAVIDROME_HOST}
                - EMAIL_APP_PASSWORD=''${EMAIL_APP_PASSWORD}
                - EMAIL_USER=''${EMAIL_USER}
                - INVITE_GEN_PW=''${INVITE_GEN_PW}
                - ADMIN_PW=''${ADMIN_PW}
                - ADMIN_UN=''${ADMIN_UN}
              ports:
                - ${if type == "prod" then "3002" else "3001"}:3000
              volumes:
                - invite-data:/usr/src/app/data
              networks:
                - web-${type}

          networks:
            web-${type}:
              external: false

          volumes:
            invite-data:
              name: invite-data
        '';

    };
}
