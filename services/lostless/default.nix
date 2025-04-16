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
    withCloudflared = true;
    inherit pkgs;
  };

  dev = import ./dev {
    type = "dev";
    filebrowserSha = "sha256-Lrr9towIexbUgaX/ItRAH5Mk8XI3fhjjVyN/egIXWV4=";
    withCloudflared = true;
    inherit pkgs;
  };

  mkService =
    {
      serviceType,
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
        ${pkgs.docker}/bin/docker build -t invite-service ${./create-user} 
        ${pkgs.docker}/bin/docker load < ${filebrowserDockerfile}

        ENV_FILE_TMP=/tmp/lostless-${serviceType}

        echo -n "TUNNEL_TOKEN=" > $ENV_FILE_TMP && cat ${
          config.sops.secrets."lostless-${serviceType}".path
        } | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "NAVIDROME_HOST=" >> $ENV_FILE_TMP && cat ${
          config.sops.secrets."navidrome-host-${serviceType}".path
        } | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "FILEBROWSER_HOST=" >> $ENV_FILE_TMP && cat ${
          config.sops.secrets."filebrowser-host-${serviceType}".path
        } | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "APP_URL=" >> $ENV_FILE_TMP && cat ${
          config.sops.secrets."app-url-${serviceType}".path
        } | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "DISCORD_WEBHOOK=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.discord-webhook.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "ADMIN_UN=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.admin-un.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "ADMIN_PW=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.admin-pw.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "INVITE_GEN_PW=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.invite-gen-pw.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "EMAIL_USER=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.email-user.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "EMAIL_APP_PASSWORD=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.email-app-password.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "DISCORD_INVITE_BOT_TOKEN=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.discord-invite-bot-token.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP
        echo -n "DISCORD_CHANNEL_ID=" >> $ENV_FILE_TMP && cat ${config.sops.secrets.discord-channel-id.path} | tr -d '\n' >> $ENV_FILE_TMP
        echo "" >> $ENV_FILE_TMP

        ${pkgs.docker}/bin/docker compose -p lostless-${serviceType} --env-file $ENV_FILE_TMP -f ${composeFile} up -d;
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
  sops.secrets.lostless-prod = {
    owner = userName;
  };
  sops.secrets.lostless-dev = {
    owner = userName;
  };
  sops.secrets.discord-webhook = {
    owner = userName;
  };
  sops.secrets.admin-un = {
    owner = userName;
  };
  sops.secrets.admin-pw = {
    owner = userName;
  };
  sops.secrets.invite-gen-pw = {
    owner = userName;
  };
  sops.secrets.email-user = {
    owner = userName;
  };
  sops.secrets.email-app-password = {
    owner = userName;
  };
  sops.secrets.navidrome-host-dev = {
    owner = userName;
  };
  sops.secrets.filebrowser-host-dev = {
    owner = userName;
  };
  sops.secrets.app-url-dev = {
    owner = userName;
  };
  sops.secrets.navidrome-host-prod = {
    owner = userName;
  };
  sops.secrets.filebrowser-host-prod = {
    owner = userName;
  };
  sops.secrets.app-url-prod = {
    owner = userName;
  };
  sops.secrets.discord-invite-bot-token = {
    owner = userName;
  };
  sops.secrets.discord-channel-id = {
    owner = userName;
  };

  systemd.services.lostless-prod = mkService {
    serviceType = "prod";
    composeFile = prod.mkComposeFile "${storagePath}/lostless-prod";
    filebrowserDockerfile = prod.filebrowserDockerfile;
  };

  systemd.services.lostless-dev = mkService {
    serviceType = "dev";
    composeFile = dev.mkComposeFile "${storagePath}/lostless-dev";
    filebrowserDockerfile = dev.filebrowserDockerfile;
  };
}
