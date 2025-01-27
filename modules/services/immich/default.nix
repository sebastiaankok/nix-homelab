{ config, lib, pkgs, ... }:
with lib;

let
  app = "immich";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "immich";
  group = "immich";
  port = 2283;

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

    systemd.tmpfiles.rules = [
      "d ${appData} 0775 ${user} ${group} -"
      "d ${libraryDir} 0775 ${user} ${group} -"
    ];

    services.${app} = {
      enable = true;
      user = "${user}";
      group = "${group}";
      mediaLocation = "${appData}";
      openFirewall = false;
      settings.server.externalDomain = "https://${app}.${domainName}";
    };

    users.users.immich.extraGroups = [ "video" "render" ];

    services.nginx = {
      enable = true;
      virtualHosts."${app}.${domainName}" = {
        useACMEHost = "${domainName}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://[::1]:${toString config.services.immich.port}";
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
     paths = [ appData ];
     #excludePath = [ "repositories" "logs"];
    });
  };
}
