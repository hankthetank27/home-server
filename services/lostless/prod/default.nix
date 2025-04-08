{
  type,
  filebrowserSha,
  pkgs,
  ...
}:
let
  checkAudioMetadata = pkgs.writeScriptBin "check-audio-metadata" (
    builtins.readFile ./check-audio-metadata.sh
  );

  convertToFlac = pkgs.writeScriptBin "convert-to-flac" (builtins.readFile ./convert-to-flac.sh);
in
{
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
        checkAudioMetadata
        convertToFlac
      ];
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

  mkComposeFile =
    appStorage:
    pkgs.writeTextFile {
      name = "compose-${type}.yml";
      text =
        #yaml
        ''
          services:
            navidrome:
              image: deluan/navidrome:latest
              container_name: navidrome-${type}
              restart: always
              environment:
                - ND_MUSICFOLDER=/music
                - ND_DATAFOLDER=/data
                - ND_UIWELCOMEMESSAGE=welcome..
                - ND_UILOGINBACKGROUNDURL=https://i.postimg.cc/ncxpBsSF/linux-bg.jpg
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
              networks:
                - web-${type}
              ports:
                - ${if type == "prod" then "8081" else "8082"}:80
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
          networks:
            web-${type}:
              external: false
        '';
    };
}
