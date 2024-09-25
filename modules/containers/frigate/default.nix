{ config, lib, pkgs, ... }:
with lib;

let
  app = "frigate";
  image = "ghcr.io/blakeblackshear/frigate:0.14.1";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "${app}";
  group = "${app}";
  port = 5000;
  uid = 1002;
  gid = 1002;
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
    ## Secrets
    sops.secrets."services/${app}/env" = {
      sopsFile = ./secrets.sops.yaml;
      owner = user;
      inherit group;
      restartUnits = [ "podman-${app}.service" ];
    };

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
      #user = "${toString uid}:${toString gid}";  # Convert uid and gid to strings
      user = "0:0";
      volumes = [
        "${appData}:/data:rw"
        "${appData}:/media:rw"
        "${appData}:/config:rw"
        "/dev/dri/renderD128:/dev/dri/renderD128"
        "/etc/localtime:/etc/localtime:ro"
      ];
      extraOptions = [
        "--mount=type=tmpfs,target=/dev/shm,tmpfs-size=128M"
        "--shm-size=128m"
        "--cap-add=CHOWN"
        "--cap-add=SETGID"
        "--cap-add=SETUID"
        "--cap-add=DAC_OVERRIDE"
        "--cap-add=CAP_PERFMON"
        "--privileged"
        "--network=host"
      ];
      ports = [ "5000:5000" "8554:8554" "8555:8555/tcp" "8555:8555/udp" ]; # expose port

      environmentFiles = [ config.sops.secrets."services/${app}/env".path ];
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."${app}.${domainName}" = {
        useACMEHost = "${domainName}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString port}";
          proxyWebsockets = true;
        };
      };
    };

    services.restic.backups = mkIf cfg.backup (config.lib.hostConfig.mkRestic {
     inherit app appData;
     paths = [ "${appData}/config" ];
     #excludePath = [ "./example"];
    });

  };
}
