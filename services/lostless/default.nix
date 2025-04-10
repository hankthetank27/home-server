{
  pkgs,
  config,
  storagePath,
  userName,
  ...
}:
let
  prod = import ./prod {
    type = "prod";
    filebrowserSha = "sha256-rwfN2vLmo7UYxYxGNWHZQ201lI3yLMPE2zZhBhcFcrQ=";
    inherit pkgs;
  };

  dev = import ./dev {
    type = "dev";
    filebrowserSha = "sha256-Lrr9towIexbUgaX/ItRAH5Mk8XI3fhjjVyN/egIXWV4=";
    withCloudflared = true;
    inherit pkgs;
  };

  prodName = "lostless-prod";
  devName = "lostless-dev";

  mkService =
    {
      serviceName,
      filebrowserDockerfile,
      composeFile,
    }:
    {
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
        ${pkgs.docker}/bin/docker load < ${filebrowserDockerfile}

        ENV_FILE_TMP=/tmp/${serviceName}

        echo -n "TUNNEL_TOKEN=" > $ENV_FILE_TMP && cat ${
          config.sops.secrets.${serviceName}.path
        } | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP

        echo -n "DISCORD_WEBHOOK=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.discord-webhook.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP

        ${pkgs.docker}/bin/docker compose -p ${serviceName} --env-file $ENV_FILE_TMP -f ${composeFile} up -d;
      '';
      serviceConfig = {
        User = userName;
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStartPre = [ "${pkgs.docker}/bin/docker compose -f ${composeFile} down --remove-orphans" ];
        ExecStop = "${pkgs.docker}/bin/docker compose -f ${composeFile} down --remove-orphans";
        Restart = "on-failure";
      };
    };
in
{
  sops.secrets.${prodName} = {
    owner = userName;
  };

  sops.secrets.${devName} = {
    owner = userName;
  };

  sops.secrets.discord-webhook = {
    owner = userName;
  };

  systemd.services.${prodName} = mkService {
    serviceName = prodName;
    composeFile = prod.mkComposeFile "${storagePath}/${prodName}";
    filebrowserDockerfile = prod.filebrowserDockerfile;
  };

  systemd.services.${devName} = mkService {
    serviceName = devName;
    composeFile = dev.mkComposeFile "${storagePath}/${devName}";
    filebrowserDockerfile = dev.filebrowserDockerfile;
  };
}
