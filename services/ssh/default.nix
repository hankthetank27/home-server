{
  config,
  ...
}:
let
  tunnelId = "bb5b25be-d87c-4661-9da3-db39ad88376d";
in
{
  sops.secrets.nixos-hp-elitedesk-ssh = {
    sopsFile = ../../secrets/nixos-hp-elitedesk-ssh.json;
    format = "json";
    key = "";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      ${tunnelId} = {
        warp-routing = true;
        credentialsFile = "${config.sops.secrets.nixos-hp-elitedesk-ssh.path}";
        default = "http_status:404";
        ingress = {

        };
      };
    };
  };
}
