let
  mediaDir = "/data/media";
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  systemd.tmpfiles.rules = [
    "d ${mediaDir}/plex 0775 plex plex -"
    "d ${mediaDir}/radarr 0775 radarr radarr -"
    "d ${mediaDir}/sonarr 0775 sonarr sonarr -"
    "d ${mediaDir}/prowlarr 0775 prowlarr prowlarr -"
  ];

  services.plex = {
    package = unstable.plex;
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

  fileSystems."/var/lib/prowlarr" = {
    device = "${mediaDir}/prowlarr";  # Your desired persistent data directory
    options = ["bind"];
  };

}
