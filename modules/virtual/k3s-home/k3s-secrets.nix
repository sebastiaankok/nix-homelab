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
  };
}
