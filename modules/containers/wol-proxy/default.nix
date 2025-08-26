{ config, lib, pkgs, ... }:
with lib;

let
  app = "wol-proxy";
  image = "ghcr.io/darksworm/go-wol-proxy:sha-22fce9ed3f41432d9c8c94941b6fa17b264e86a8";
  cfg = config.hostConfig.services.${app};
  appData = config.hostConfig.dataDir + "/${app}";
  domainName = config.hostConfig.domainName;
  port = 8085;
  uid = 65534;
  gid = 65534;

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

    virtualisation.oci-containers.containers.${app} = {
      autoStart = true;
      image = "${image}";
      user = "${builtins.toString uid}:${builtins.toString gid}";
      volumes = [
        "${appData}/config.toml:/app/config.toml"
        "/etc/localtime:/etc/localtime:ro"
      ];

      ports = [ "127.0.0.1:${builtins.toString port}:${builtins.toString port}" ];
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."ollama.${domainName}" = {
        useACMEHost = "${domainName}";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${builtins.toString port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
