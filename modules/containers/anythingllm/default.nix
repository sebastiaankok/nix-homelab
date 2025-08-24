{ config, lib, pkgs, ... }:
with lib;

let
  app = "anythingllm";
  image = "mintplexlabs/anythingllm:1.8";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  user = "${app}";
  group = "${app}";
  port = 3001;
  uid = 1000;
  gid = 1000;
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
      gid = gid; # Set the GID explicitly
    };

    # Create the user, assign to the group, and set a specific UID
    users.users.${user} = {
      isSystemUser = true; # Ensures the user is treated as a system user
      uid = uid; # Explicitly set the UID
      group = "${group}"; # Assign the user to the predefined group
      home = "${appData}"; # Define home directory for the service
      createHome = true; # Automatically create the home directory
    };

    systemd.tmpfiles.rules = [
      "d ${appData} 0750 ${user} ${group} -" # Create storage directory with appropriate permissions
      "f ${appData}/.env 0640 ${user} ${group} -" # Create .env file with appropriate permissions
    ];

    virtualisation.oci-containers.containers.${app} = {
      autoStart = true;
      image = "${image}";
      user = "${toString uid}:${toString gid}"; # Use the specified UID and GID
      volumes = [
        "${appData}:/app/server/storage:rw" # Mount storage directory as per Docker instructions
        "${appData}/.env:/app/server/.env:rw"
      ];
      ports = [ "127.0.0.1:${toString port}:${toString port}" ]; # Map port 3001

      environment = {
        STORAGE_DIR="/app/server/storage";
      };
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
      paths = [ "${appData}" ]; # Backup the entire appData directory, including .env and storage
    });
  };
}
