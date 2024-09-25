{ config, lib, pkgs, pkgs-unstable, ... }:
with lib;

let
  app = "mealie";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  port = 9000;

in
{

  options.hostConfig.services.${app} = {
    enable = mkEnableOption "${app}";
    backup = mkOption {
      type = lib.types.bool;
      description = "Enable backups";
      default = true;
    };
  };

  config = mkIf cfg.enable {

    systemd.services.${app}.serviceConfig.ReadWritePaths = lib.mkForce [ "${appData}" ];
    services.${app} = {
      package = pkgs-unstable.${app};
      enable = true;
      port = port;
      settings = {
        ALLOW_SIGNUP = "false";
        BASE_URL = "https://${app}.${domainName}";
        DATA_DIR = "${appData}";
        ALEMBIC_CONFIG_FILE="${pkgs-unstable.mealie}/alembic.ini";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${app}.${domainName}" = {
        useACMEHost = "${domainName}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
        };
      };
    };

    services.restic.backups = mkIf cfg.backup (config.lib.hostConfig.mkRestic {
     inherit app appData;
     paths = [ appData ];
     excludePath = [ "logs" ];
    });

  };
}
