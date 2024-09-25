{ config, lib, pkgs, pkgs-unstable, ... }:
with lib;

let
  app = "sabnzbd";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "media";
  group = "media";
  port = 9080;

  libraryDir = config.hostConfig.dataDir + "/library";
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

    users.groups.media = {};
    users.users.media = {
      group = "media";
      isSystemUser = true;
    };

    systemd.tmpfiles.rules = [
      "d ${appData} 0775 ${user} ${group} -"
      "d ${libraryDir} 0775 ${user} ${group} -"
    ];

    services.${app} = {
      package = pkgs-unstable.${app};
      enable = true;
      user = "${user}";
      group = "${group}";
      configFile = "${appData}/sabnzbd.ini";
      openFirewall = false;
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
     excludePath = [ "logs"];
    });

  };
}
