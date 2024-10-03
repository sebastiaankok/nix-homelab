{ config, lib, ...}:
{

  config = {
    hostConfig = {
      dataDir = "/data";
      domainName = (import ./secrets.nix).domainName;
      user = "sebastiaan";
      interface = "enp0s31f6";
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
        mealie.enable = true;
        # system
        prometheus.enable = true;
      };
    };
  };

  # Host-specific configuration options
  imports = [
    ./hardware-configuration.nix
  ];

}
