{ config, lib, ...}:
{

  config = {
    hostConfig = {
      dataDir = "/data";
      domainName = "REDACTED";
      system = {
        acme = {
          enable = true;
        };
      };
      services = {
        # nvr
        frigate.enable = true;
        # home automation
        home-assistant.enable = true;
        zigbee2mqtt.enable = true;
        mosquitto.enable = true;
        # media
        plex.enable = true;
        radarr.enable = true;
        sonarr.enable = true;
        prowlarr.enable = true;
        sabnzbd.enable = true;
        overseerr.enable = true;
      };
    };
  };

  # Host-specific configuration options

  imports = [
    ./hardware-configuration.nix
  ];

}
