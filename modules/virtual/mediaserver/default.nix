{ pkgs, pkgs-unstable, lib, inputs, self, config, ... }:
with lib;

let
  app = "mediaserver";

  cfg = {
    domainName = config.hostConfig.domainName;
    dirs = {
      jellyfinDir = config.hostConfig.dataDir + "/jellyfin";
      jellyseerrDir = config.hostConfig.dataDir + "/jellyseerr";
      sonarrDir = config.hostConfig.dataDir + "/sonarr";
      radarrDir = config.hostConfig.dataDir + "/radarr";
      bazarrDir = config.hostConfig.dataDir + "/bazarr";
      prowlarrDir = config.hostConfig.dataDir + "/prowlarr";
      sabnzbdDir = config.hostConfig.dataDir + "/sabnzbd";
      libraryDir = config.hostConfig.dataDir + "/library";
    };

    user = "media";
    group = "media";

    vm = {
      hostname = "mediaserver";
      hypervisor = "cloud-hypervisor";
      mac = "02:22:de:ad:be:ea";
      cpu = 2;
      memory = 4096;
      network_mode = "private";
      interface = config.hostConfig.interface;
      user = config.hostConfig.user;
      ssh_public_key = config.hostConfig.sshPublicKey;
    };
  };

in
{
  microvm.vms."${cfg.vm.hostname}" = {
    autostart = true;

    config = {

      # Import VM configuration interface, disks
      microvm = import ./vm.nix { cfg = cfg; lib = lib; };

      # Import system and application configuration
      imports = [
        (import ./system.nix { inherit cfg; })
      ];

      networking = {
        firewall.allowedTCPPorts = [ 443 ];
      };

      users.groups."${cfg.group}" = {
      	gid = 990;
      };
      users.groups.acme = {
        gid = 992;
      };
      users.users."${cfg.user}" = {
        group = "${cfg.group}";
        isSystemUser = true;
        uid = 992;
      };
      users.users.nginx = {
        isSystemUser = true;
        extraGroups = [ "acme" ];
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dirs.jellyfinDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.sonarrDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.radarrDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.prowlarrDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.bazarrDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.sabnzbdDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.jellyseerrDir} 0775 ${cfg.user} ${cfg.group} -"
        "d ${cfg.dirs.libraryDir} 0775 ${cfg.user} ${cfg.group} -"
      ];

      services.jellyfin = {
        package = pkgs-unstable.jellyfin;
        enable = true;
        user = "${cfg.user}";
        group = "${cfg.group}";
        dataDir = "${cfg.dirs.jellyfinDir}";
        openFirewall = false;
      };

      services.jellyseerr = {
        enable = true;
        openFirewall = false;
      };

      # Fix for jellyseerr that forces dataDir
      systemd.services.jellyseerr.serviceConfig.BindPaths = lib.mkForce [
        "${cfg.dirs.jellyseerrDir}/:${pkgs.jellyseerr}/libexec/jellyseerr/deps/jellyseerr/config/"
      ];
      systemd.services.jellyseerr.serviceConfig.ReadWritePaths = [ "${cfg.dirs.jellyseerrDir}" ];
      systemd.services.jellyseerr.serviceConfig.Group = "${cfg.group}";


      services.radarr = {
        package = pkgs-unstable.radarr;
        enable = true;
        user = "${cfg.user}";
        group = "${cfg.group}";
        dataDir = "${cfg.dirs.radarrDir}";
        openFirewall = false;
      };

      services.sonarr = {
        package = pkgs-unstable.sonarr;
        enable = true;
        user = "${cfg.user}";
        group = "${cfg.group}";
        dataDir = "${cfg.dirs.sonarrDir}";
        openFirewall = false;
      };

      services.prowlarr = {
        package = pkgs-unstable.prowlarr;
        enable = true;
        openFirewall = false;
      };

      systemd.services.prowlarr.serviceConfig.DynamicUser = lib.mkForce false;

      # Fix for prowlarr that mounts the private /var/lib directory to dataDir
      fileSystems."/var/lib/prowlarr" = {
        device = "${cfg.dirs.prowlarrDir}";  # Your desired persistent data directory
        options = ["bind"];
      };

      services.sabnzbd = {
        package = pkgs-unstable.sabnzbd;
        enable = true;
        user = "${cfg.user}";
        group = "${cfg.group}";
        configFile = "${cfg.dirs.sabnzbdDir}/sabnzbd.ini";
        openFirewall = false;
      };

      services.bazarr = {
        enable = true;
        user = "${cfg.user}";
        group = "${cfg.group}";
        openFirewall = false;
      };

      # Fix for bazarr that mounts the private /var/lib directory to dataDir
      fileSystems."/var/lib/bazarr" = {
        device = "${cfg.dirs.bazarrDir}";  # Your desired persistent data directory
        options = ["bind"];
      };

      services.nginx = {
        enable = true;
        virtualHosts."jellyfin.${cfg.domainName}" = {
        serverAliases = [ "tv.${cfg.domainName}"];
        default = true;
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
          };
        };
        virtualHosts."jellyseerr.${cfg.domainName}" = {
        serverAliases = [ "hub.${cfg.domainName}"];
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:5055";
            proxyWebsockets = true;
          };
        };
        virtualHosts."radarr.${cfg.domainName}" = {
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:7878";
            proxyWebsockets = true;
            extraConfig = ''
              allow 127.0.0.1;
              allow 10.0.0.0/8;
              deny all;               # Deny all other traffic
            '';
          };
        };
        virtualHosts."sonarr.${cfg.domainName}" = {
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8989";
            proxyWebsockets = true;
            extraConfig = ''
              allow 127.0.0.1;
              allow 10.0.0.0/8;
              deny all;               # Deny all other traffic
            '';
          };
        };
        virtualHosts."prowlarr.${cfg.domainName}" = {
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9696";
            proxyWebsockets = true;
            extraConfig = ''
              allow 127.0.0.1;
              allow 10.0.0.0/8;
              deny all;               # Deny all other traffic
            '';
          };
        };
        virtualHosts."sabnzbd.${cfg.domainName}" = {
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9080";
            proxyWebsockets = true;
            extraConfig = ''
              allow 127.0.0.1;
              allow 10.0.0.0/8;
              deny all;               # Deny all other traffic
            '';
          };
        };
        virtualHosts."bazarr.${cfg.domainName}" = {
         sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
         sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:6767";
            proxyWebsockets = true;
            extraConfig = ''
              allow 127.0.0.1;
              allow 10.0.0.0/8;
              deny all;               # Deny all other traffic
            '';
          };
        };
      };
    };
  };

  services.restic.backups = (config.lib.hostConfig.mkRestic {
   inherit app;
   paths = [ cfg.dirs.jellyfinDir cfg.dirs.jellyseerrDir cfg.dirs.radarrDir cfg.dirs.sonarrDir cfg.dirs.prowlarrDir cfg.dirs.bazarrDir cfg.dirs.sabnzbdDir  ];
   excludePath = [
    "metadata"
    "logs"
    "repositories"
    "Definitions"
   ];
  });
}
