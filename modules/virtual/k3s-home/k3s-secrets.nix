{ cfg, config, pkgs, pkgs-unstable, ... }:
{
  sops = {
    keepGenerations = 0;
    secrets."k3s-home/cloudflare-api.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
    secrets."k3s-home/frigate.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
    secrets."k3s-home/velero-repo-password.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
    secrets."k3s-home/velero-b2-credentials.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
    secrets."k3s-home/cnpg-b2-credentials.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
    secrets."k3s-home/postgresql-17-postgresql-user-immich.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
    secrets."k3s-home/immich-postgresql-user-immich.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}
