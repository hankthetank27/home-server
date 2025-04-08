{
  pkgs,
  config,
  storagePath,
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
    inherit pkgs;
  };

  prodName = "lostless-prod";
  devName = "lostless-dev";

  mkService =
    {
      tokenName,
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
        ENV_FILE_TMP=/tmp/${tokenName}
        echo -n "TUNNEL_TOKEN=" > $ENV_FILE_TMP && cat ${
          config.sops.secrets.${tokenName}.path
        } | tr -d '\n' >> $ENV_FILE_TMP
        ${pkgs.docker}/bin/docker compose -p ${tokenName} --env-file $ENV_FILE_TMP -f ${composeFile} up -d;
      '';
      serviceConfig = {
        User = "hjackson";
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
    owner = "hjackson";
  };

  sops.secrets.${devName} = {
    owner = "hjackson";
  };

  systemd.services.${prodName} = mkService {
    tokenName = prodName;
    composeFile = prod.mkComposeFile "${storagePath}/${prodName}";
    filebrowserDockerfile = prod.filebrowserDockerfile;
  };

  systemd.services.${devName} = mkService {
    tokenName = devName;
    composeFile = dev.mkComposeFile "${storagePath}/${devName}";
    filebrowserDockerfile = dev.filebrowserDockerfile;
  };
}
