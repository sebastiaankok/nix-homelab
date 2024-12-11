{ config, lib, pkgs, ... }:
with lib;

let
  app = "home-assistant";
  image = "ghcr.io/home-assistant/home-assistant:2024.12.2";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "${app}";
  group = "${app}";
  uid = 1001;
  gid = 1001;
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
    # Create the group first, with a specific GID
    users.groups.${group} = {
      gid = gid;  # Set the GID explicitly
    };

    # Create the user, assign to the group, and set a specific UID
    users.users.${user} = {
      isSystemUser = true;  # Ensures the user is treated as a system user
      uid = uid;  # Explicitly set the UID
      group = "${group}";  # Assign the user to the predefined group
      home = "${appData}";  # Define home directory for the service
      createHome = true;  # Automatically create the home directory
    };

    systemd.tmpfiles.rules = [
      "d ${appData} 0750 ${user} ${group} -" #The - disables automatic cleanup, so the file wont be removed after a period
    ];

    virtualisation.oci-containers.containers.${app} = {
      autoStart = true;
      image = "${image}";
      user = "${toString uid}:${toString gid}";  # Convert uid and gid to strings
      volumes = [
        "${appData}:/config:rw"
        "/etc/localtime:/etc/localtime:ro"
      ];
      extraOptions = [
        "--device=/dev/ttyUSB0"
        "--device=/dev/ttyUSB1"
        "--device=/dev/ttyUSB2"
        "--device=/dev/ttyUSB3"
        "--device=/dev/serial/by-id/"
        "--network=host"
        "--privileged"
      ];
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."hass.${domainName}" = {
        useACMEHost = "${domainName}";
        forceSSL = true;
        extraConfig = ''
          proxy_buffering off;
        '';
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123";
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
