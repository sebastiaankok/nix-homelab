{ config, lib, pkgs, ... }:
with lib;

let
  app = "mosquitto";
  image = "public.ecr.aws/docker/library/eclipse-mosquitto:2.0.20";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "${app}";
  group = "${app}";
  uid = 1005;
  gid = 1005;
  port = 1883;
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
        "${appData}/mosquitto.conf:/mosquitto/config/mosquitto.conf:rw"
        "${appData}:/mosquitto/data:rw"
        "/etc/localtime:/etc/localtime:ro"
      ];
      extraOptions = [
        "--network=host"
      ];
    };

    networking = {
      firewall.allowedTCPPorts = [
        1883
      ];
    };

    services.restic.backups = mkIf cfg.backup (config.lib.hostConfig.mkRestic {
     inherit app appData;
     paths = [ appData ];
     #excludePath = [ "./example"];
    });

  };
}
