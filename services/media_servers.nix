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

  # create bind mount so we can use custom data directory for prowlarr

  systemd.mounts."prowlarr-data" = {
    unit = "prowlarr.service";
    source = "${mediaDir}/prowlarr";
    target = "/var/lib/prowlarr";
    options = [ "bind" ];
  };

}
