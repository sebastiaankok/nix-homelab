{
  name = "argo-cd";
  targetNamespace = "argocd";
  createNamespace = true;
  repo = "https://argoproj.github.io/argo-helm";
  version = "8.3.4"; # pick the version you want
  hash = "sha256:7014017a6c327bd6c682ad71f866f4a0e11508a01e9c39af1b1d8151186cbd61";
  values = {
    global = {
      domain = "argocd.otohgunga.nl";
    };
    configs = {
      params = {
        "server.insecure" = true;
      };
    };
    server = {
      ingress = {
        enabled = true;
        ingressClassName = "nginx";
        annotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-dns";
          "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true";
          "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP";
        };
        extraTls = [
          {
            hosts = [ "argocd.otohgunga.nl" ];
            # secretName is optional depending on ingress controller
            secretName = "argocd-https-tls";
          }
        ];
      };
    };
  };
  extraDeploy = [
    {
      apiVersion = "argoproj.io/v1alpha1";
      kind = "Application";
      metadata = {
        name = "gitops-ctrl";
        namespace = "argocd";
      };
      spec = {
        project = "default";
        source = {
          repoURL = "https://github.com/sebastiaankok/k8s-homelab.git";
          path = "clusters/k8s-home/argocd/apps";
          targetRevision = "HEAD";
          directory = {
            recurse = true;
            include = "*/application.yaml";
            jsonnet = {};
          };
        };
        destination = {
          name = "in-cluster";
          namespace = "argocd";
        };
        syncPolicy = {};
      };
    }
  ];
}
