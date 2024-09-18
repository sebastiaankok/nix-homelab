let
  mediaDir = "/data/media";
in
{
    systemd.tmpfiles.rules = [
      "d ${mediaDir}/plex 0775 plex plex -"
      "d ${mediaDir}/radarr 0775 radarr radarr -"
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

}
