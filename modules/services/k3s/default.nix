{ config, lib, pkgs, ... }:
with lib;

let
  app = "k3s";
  cfg = config.hostConfig.services.${app};
  domainName = config.hostConfig.domainName;
  user = "k3s";
  group = "k3s";
  port = 6443;

in
{

  options.hostConfig.services.${app} = {
    enable = mkEnableOption "${app}";
  };

  config = mkIf cfg.enable {

    users.users.${user} = {
      isSystemUser = true;
      group = "${group}";
    };

    users.groups.${group} = {};

    # Enable k3s service
    services.k3s = {
      enable = true;
      role = "server";
      extraFlags = [
        "--disable traefik"
        "--disable local-storage"
        "--disable-network-policy"
      ];
    };

    networking.firewall.allowedTCPPorts = [ 
      443 
      6443
      10250
    ];

    # Set up k3s directory structure
    systemd.tmpfiles.rules = [
      "d /var/lib/k3s 0755 ${user} ${group} -"
    ];
  };
}
