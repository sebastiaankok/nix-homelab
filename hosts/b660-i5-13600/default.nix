{ config, lib, ...}:
{
  config = {
    hostConfig = {
      dataDir = "/data";
      domainName = (import ./secrets.nix).domainName;
      user = "sebastiaan";
      interface = "enp3s0";
      sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTvwNAE0ZUIgEZRlZqw48o5Sw8gZuCPaYUPUHEp/vtg sebastiaan@linux.com";
      system = {
        acme = {
          enable = true;
        };
      };
      services = {
        # photos
        immich = {
          enable = true;
        };
        # nvr
        frigate.enable = true;
        # home automation
        home-assistant.enable = true;
        mosquitto.enable = true;
        zigbee2mqtt.enable = true;
        kamstrup-mqtt.enable = true;
        # system
        prometheus.enable = true;
        # ai
        anythingllm.enable = true;
        # network
        wol-proxy.enable = true; # Added wol-proxy service and enabled it.
      };
    };
  };

  # Host-specific configuration options
  imports = [
    ./hardware-configuration.nix
  ];

}
