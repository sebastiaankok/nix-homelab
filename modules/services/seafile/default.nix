{ config, lib, pkgs, ... }:
with lib;

let
  app = "seafile";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "seafile";
  group = "seafile";
  port = 8000;

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

    systemd.tmpfiles.rules = [
      "d ${appData}/seafile-data 0755 ${user} ${group} -"
      "d ${appData}/seahub-data 0755 ${user} ${group} -"
    ];

    services.${app} = {
      enable = true;
      user = "${user}";
      group = "${group}";
      dataDir = "${appData}/seafile-data";
      seahubPort = port;
      openFirewall = false;
      settings.server.externalDomain = "https://${app}.${domainName}";
    };

    users.users.${user} = {
      isSystemUser = true;
      createHome = true;
      homeDirectory = appData;
      extraGroups = [ "video" "render" ];
    };

    services.nginx = {
      enable = true;
      virtualHosts."${app}.${domainName}" = {
        useACMEHost = "${domainName}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:${toString port}";
          proxyWebsockets = true;
        };
        # Allow large files to be uploaded
        extraConfig = ''
          client_max_body_size 10000m;
        '';
      };
    };

    services.restic.backups = mkIf cfg.backup (config.lib.hostConfig.mkRestic {
      inherit app appData;
      paths = [ "${appData}/seafile-data" ];
      #excludePath = [ "repositories" "logs"];
    });
  };
}
