{ config, lib, pkgs, pkgs-unstable, ... }:
with lib;

let
  app = "k3s";
  cfg = config.hostConfig.services.${app};
  domainName = config.hostConfig.domainName;
  port = 6443;
in
{
  options.hostConfig.services.${app} = {
    enable = mkEnableOption "${app}";
  };

  config = mkIf cfg.enable {

    # Enable k3s service
    services.k3s = {
      enable = true;
      #package = pkgs.k3s_1_33;
      role = "server";
      extraFlags = [
        "--disable traefik"
        "--disable local-storage"
        #"--disable servicelb"
        #"--disable-network-policy"
      ];
      autoDeployCharts = {
        argocd = {
          name = "argo-cd";
          targetNamespace = "argocd";
          createNamespace = true;
          repo = "https://argoproj.github.io/argo-helm";
          version = "8.3.4"; # pick the version you want
          hash = "sha256:7014017a6c327bd6c682ad71f866f4a0e11508a01e9c39af1b1d8151186cbd61";
        };
      };
    };

    #networking.firewall.checkReversePath = false;
    #networking.firewall.trustedInterfaces = [ "cni0" "flannel.1"];
    networking.firewall.allowedTCPPorts = [ 
      443  #https
      6443 #kube-api
      1883 #mqtt
    ];
    #networking.firewall.allowedUDPPorts = [
    #  53
    #  8472
    #];
  };
}
