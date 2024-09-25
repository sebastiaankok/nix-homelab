{ config, lib, pkgs, pkgs-unstable, ... }:
with lib;

let
  app = "zigbee2mqtt";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "${app}";
  group = "${app}";
  port = 8080;
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
    ];

    services.zigbee2mqtt = {

      package = pkgs-unstable.zigbee2mqtt;
      enable = true;

      dataDir = "${appData}";

      settings = {
      # Define the files which contains the configs
        advanced = {
          homeassistant_discovery_topic = "homeassistant";
          homeassistant_status_topic = "homeassistant/status";
          last_seen = "ISO_8601";
          log_level = "warning";
          log_output = [ "console" ];
          network_key = [ 201 21 77 20 148 67 55 210 61 44 6 36 85 251 87 233 ];
          transmit_power = 20;
        };
        experimental = {
          new_api = true;
        };
        frontend = {
          port = port;
        };
        homeassistant = true;
        mqtt = {
          base_topic = "zigbee2mqtt";
          include_device_information = true;
          server = "mqtt://mosquitto.${domainName}:1883";
        };
        permit_join = false;
        serial = {
          port = "tcp://rpi4-ser2net.${domainName}:20108";
        };
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."zigbee2mqtt.${domainName}" = {
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
     #excludePath = [ "./example"];
    });

  };
}
