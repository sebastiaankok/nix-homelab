let
  mediaDir = "/data/media";
in
{
  systemd.tmpfiles.rules = [
    "d ${mediaDir}/plex 0775 plex plex -"
    "d ${mediaDir}/radarr 0775 radarr radarr -"
    "d ${mediaDir}/sonarr 0775 sonarr sonarr -"
    "d ${mediaDir}/prowlarr 0775 prowlarr prowlarr -"
  ];

  services.plex = {
    enable = true;
    dataDir = "${mediaDir}/plex/Library/Application Support";
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    dataDir = "${mediaDir}/radarr";
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    dataDir = "${mediaDir}/sonarr";
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # Set custom data directory for prowlarr
  systemd.services.prowlarr.environment = {
    PROWLARR_DATA = "${mediaDir}/prowlarr";
  };

}
