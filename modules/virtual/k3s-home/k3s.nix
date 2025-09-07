{ cfg, pkgs, pkgs-unstable, ... }:
{
  services.k3s = {
    enable = true;
    #package = pkgs.k3s_1_33;
    role = "server";
    #gracefulNodeShutdown.enable = true;

    extraFlags = [
      "--disable traefik"
      "--disable local-storage"
      "--disable servicelb"
      "--disable-network-policy"
      "--disable-kube-proxy"
      "--flannel-backend=none"
    ];

    manifests = {
      copy-secrets-job = {
        enable = true;
        target = "copy-secrets-job.yaml";
        content = {
          apiVersion = "batch/v1";
          kind = "Job";
          metadata = {
            name = "copy-secrets-to-manifests";
            namespace = "kube-system";
          };
          spec = {
            template = {
              spec = {
                restartPolicy = "OnFailure";
                containers = [
                  {
                    name = "copy-secrets";
                    image = "busybox:latest";
                    command = [
                      "sh"
                      "-c"
                      ''
                        mkdir -p /manifests
                        cp /mounted-secrets/*.yaml /manifests/
                      ''
                    ];
                    volumeMounts = [
                      {
                        name = "secrets";
                        mountPath = "/mounted-secrets";
                      }
                      {
                        name = "k3s-manifests";
                        mountPath = "/manifests";
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "secrets";
                    hostPath = {
                      path = "/var/run/secrets";
                      type = "Directory";
                    };
                  }
                  {
                    name = "k3s-manifests";
                    hostPath = {
                      path = "/var/lib/rancher/k3s/server/manifests";
                      type = "Directory";
                    };
                  }
                ];
              };
            };
          };
        };
      };
    };

    autoDeployCharts = {
      argocd = {
        name = "argo-cd";
        targetNamespace = "argocd";
        createNamespace = true;
        repo = "https://argoproj.github.io/argo-helm";
        version = "8.3.4"; # pick the version you want
        hash = "sha256:7014017a6c327bd6c682ad71f866f4a0e11508a01e9c39af1b1d8151186cbd61";
      };
      cilium = {
        name = "cilium";
        #package = ciliumChart;
        targetNamespace = "kube-system"; # Cilium usually runs in kube-system
        repo = "https://helm.cilium.io/";
        version = "1.18.1";
        hash = "sha256:NqqIK+KjWsafcI9uYuHh+XX/SMVhzgedNa01cYKEryI=";
        values = {
          operator.replicas = 1;
          kubeProxyReplacement = true;
          ipam.operator.clusterPoolIPv4PodCIDRList = "10.42.0.0/16";
          tunnelProtocol = "geneve";
          l2announcements.enabled = true;
          l2announcements.leaseDuration = "120s";
          l2announcements.leaseRenewDeadline = "60s";
          l2announcements.leaseRetryPeriod = "10s";
          externalIPs.enabled = true;
          k8sServiceHost = "127.0.0.1";
          k8sServicePort = 6443;
        };
        extraFieldDefinitions = {
          spec = {
            repo = "https://helm.cilium.io/";
            chart = "cilium";
            version = "1.18.1";
            bootstrap = true;
          };
        };
        extraDeploy = [
          {
            apiVersion = "cilium.io/v2";
            kind = "CiliumLoadBalancerIPPool";
            metadata = {
              name = "all";
            };
            spec = {
              blocks = [
                {
                  start = "10.10.21.30";
                  stop  = "10.10.21.100";
                }
              ];
            };
          }
          {
            apiVersion = "cilium.io/v2alpha1";
            kind = "CiliumL2AnnouncementPolicy";
            metadata = {
              name = "policy-all";
            };
            spec = {
              interfaces = [ "^ens[0-9]+" ];
              externalIPs = true;
              loadBalancerIPs = true;
            };
          }
        ];
      };
    };
  };

  networking.firewall.enable = false;
}
