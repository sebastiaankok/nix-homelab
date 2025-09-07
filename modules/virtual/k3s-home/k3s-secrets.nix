{ cfg, config, pkgs, pkgs-unstable, ... }:
{
  sops = {
    secrets."k3s-home/cloudflare-api.yaml" = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}
