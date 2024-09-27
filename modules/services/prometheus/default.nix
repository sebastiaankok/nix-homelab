{ config, lib, pkgs, pkgs-unstable, ... }:
with lib;

let
  app = "prometheus";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
in
{

  options.hostConfig.services.${app} = {
    enable = mkEnableOption "${app}";
    backup = mkOption {
      type = lib.types.bool;
      description = "Enable backups";
      default = false;
    };
  };

  config = mkIf cfg.enable {

    sops.secrets."services/${app}/password" = {
      sopsFile = ./secrets.sops.yaml;
      restartUnits = [ "${app}.service" ];
    };

    services.${app} = {
      package = pkgs-unstable.${app};
      enable = true;
      enableReload = true;
      enableAgentMode = true;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
        };
      };

      scrapeConfigs = [
        {
          job_name = "${config.networking.hostName}-node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              ];
                labels.instance = config.networking.hostName;
            }
          ];
        }
      ];

      remoteWrite = [
        {
          name = "grafana-cloud";
          url = "https://prometheus-prod-24-prod-eu-west-2.grafana.net/api/prom/push";
          basic_auth = {
            username = "1680587";
            password_file = config.sops.secrets."services/${app}/password".path;
          };
        }
      ];
    };

    services.restic.backups = mkIf cfg.backup (config.lib.hostConfig.mkRestic {
     inherit app appData;
     paths = [ appData ];
    });
  };
}