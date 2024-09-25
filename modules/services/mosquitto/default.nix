{ config, lib, pkgs, ... }:
with lib;

let
  app = "mosquitto";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  user = "${app}";
  group = "${app}";
  port = 1883;
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

    systemd.tmpfiles.rules = [
      "d ${appData} 0775 ${user} ${group} -"
    ];

    services.mosquitto = {

      enable = true;
      dataDir = "${appData}";
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          address = "0.0.0.0";
          port = port;
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];

    };

    networking.firewall.allowedTCPPorts = [ port ];

    services.restic.backups = mkIf cfg.backup (config.lib.hostConfig.mkRestic {
     inherit app appData;
     paths = [ appData ];
     #excludePath = [ "./example"];
    });

  };
}
