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
      enable = true;
      port = port;
      settings = {
        BASE_URL = "mealie.${domainName}";
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
