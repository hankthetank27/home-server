{
  pkgs,
  ...
}:
let
  prometheusConfig = pkgs.writeTextFile {
    name = "prometheus.yml";
    text = # yaml
      ''
        global:
          scrape_interval: 15s
          evaluation_interval: 15s
        rule_files: # We will setup alerting at some point..
          - "alert.rules"
        scrape_configs:
          - job_name: "nodeexporter"
            scrape_interval: 5s
            static_configs:
              - targets: [ "nodeexporter:9100" ]
          - job_name: "cadvisor"
            scrape_interval: 5s
            static_configs:
              - targets: [ "cadvisor:8080" ]
          - job_name: "prometheus"
            scrape_interval: 10s
            static_configs:
              - targets: ["127.0.0.1:9090"]
      '';
  };

  caddyConfig = pkgs.writeTextFile {
    name = "Caddyfile";
    text = ''
      :80 :443 {
        reverse_proxy grafana:3000
      }
    '';
  };

  composeFile = pkgs.writeTextFile {
    name = "monitoring.yml";
    text = # yaml
      ''
        services:
          prometheus:
            image: prom/prometheus
            container_name: prometheus
            restart: unless-stopped
            volumes:
              - prometheus_data:/prometheus
              - ${prometheusConfig}:/etc/prometheus/prometheus.yml
            command:
              - "--config.file=/etc/prometheus/prometheus.yml"
              - "--storage.tsdb.path=/prometheus"
              - "--web.console.libraries=/etc/prometheus/console_libraries"
              - "--web.console.templates=/etc/prometheus/consoles"
              - "--storage.tsdb.retention.time=200h"
              - "--web.enable-lifecycle"
            ports:
              - 9090:9090
            depends_on:
              - nodeexporter
            networks:
              - monitoring

          nodeexporter:
            image: prom/node-exporter
            restart: unless-stopped
            container_name: nodeexporter
            ports:
              - 9100:9100
            volumes:
              - /proc:/host/proc:ro
              - /sys:/host/sys:ro
              - /:/rootfs:ro
            command:
              - "--path.procfs=/host/proc"
              - "--path.rootfs=/rootfs"
              - "--path.sysfs=/host/sys"
              - "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)"
            networks:
              - monitoring

          cadvisor:
            image: gcr.io/cadvisor/cadvisor:latest
            container_name: cadvisor
            restart: unless-stopped
            volumes:
              - /:/rootfs:ro
              - /var/run:/var/run:rw
              - /sys:/sys:ro
              - /var/lib/docker/:/var/lib/docker:ro
              - /dev/disk/:/dev/disk:ro
            command:
              - "--docker_only=true"
              - "--housekeeping_interval=10s"
            ports:
              - 8080:8080
            networks:
              - monitoring

          grafana:
            image: grafana/grafana
            container_name: grafana
            environment:
              GF_INSTALL_PLUGINS: "grafana-clock-panel,grafana-simple-json-datasource"
            restart: unless-stopped
            volumes:
              - grafana_data:/var/lib/grafana
            ports:
              - 3000:3000
            depends_on:
              - prometheus
            networks:
              - monitoring

          caddy:
            image: caddy:latest
            container_name: caddy-monitoring
            restart: unless-stopped
            hostname: caddy
            ports:
              - 80:80
              - 443:443
            volumes:
              - caddy_data:/data
              - caddy_config:/config
              - ${caddyConfig}:/etc/caddy/Caddyfile
            depends_on:
              - grafana
            networks:
              - monitoring

        volumes:
          prometheus_data:
          grafana_data:
          caddy_data:
          caddy_config:

        networks:
          monitoring:
            external: false
      '';
  };
in
{
  systemd.services.grafana-monitoring = {
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
      ${pkgs.docker}/bin/docker compose -p grafana-monitoring -f ${composeFile} up -d;
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
}
