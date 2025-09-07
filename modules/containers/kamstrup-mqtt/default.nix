{ config, lib, pkgs, ... }:
with lib;

let
  app = "kamstrup-mqtt";
  image = "ghcr.io/sebastiaankok/kamstrup-402-mqtt:900ec8a4dddd97e6216989765f74a601c71a8b7b";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "${app}";
  group = "${app}";
  uid = 1003;
  gid = 1003;
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

    systemd.services.socat-serial = {
      description = "socat virtual serial port for ser2net";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /dev/ser2net";
        ExecStart = "${pkgs.socat}/bin/socat pty,raw,echo=0,link=/dev/ser2net/kamstrup-serial,mode=0660,owner=1003 tcp:10.10.30.102:20408";
        Restart = "always";
      };
    };

    ## Secrets
    # sops.secrets."services/${app}/config" = {
    #   sopsFile = ./secrets.sops.yaml;
    #   owner = user;
    #   inherit group;
    #   restartUnits = [ "podman-${app}.service" ];
    # };

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
        "/data/kamstrup-mqtt/config.yaml:/opt/kamstrup/config.yaml:ro"
        "/dev/ser2net/kamstrup-serial:/dev/ser2net/kamstrup-serial"
      ];
      extraOptions = [
        "--network=host"
      ];
    };
  };
}
