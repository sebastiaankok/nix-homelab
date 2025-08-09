{ pkgs, pkgs-unstable, lib, inputs, self, config, ... }:
with lib;

let

  app = "mediaserver";

  cfg = {
    domainName = config.hostConfig.domainName;
    dirs = {
      jellyfinDir = config.hostConfig.dataDir + "/mediaserver/jellyfin";
      jellyseerrDir = config.hostConfig.dataDir + "/mediaserver/jellyseerr";
      sonarrDir = config.hostConfig.dataDir + "/mediaserver/sonarr";
      radarrDir = config.hostConfig.dataDir + "/mediaserver/radarr";
      bazarrDir = config.hostConfig.dataDir + "/mediaserver/bazarr";
      prowlarrDir = config.hostConfig.dataDir + "/mediaserver/prowlarr";
      lidarrDir = config.hostConfig.dataDir + "/mediaserver/lidarr";
      sabnzbdDir = config.hostConfig.dataDir + "/mediaserver/sabnzbd";
      libraryDir = config.hostConfig.dataDir + "/library";
    };

    user = "media";
    group = "media";

    vm = {
      hostname = "mediaserver";
      hypervisor = "qemu" ;
      mac = "02:22:de:ad:be:ea";
      cpu = 6;
      memory = 16392;
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

    pkgs = pkgs-unstable;

    config = {

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-vaapi-driver
          vaapiVdpau
          intel-compute-runtime
          vpl-gpu-rt
        ];
      };

      fileSystems."/" = {
        device = "rootfs";
        fsType = "tmpfs";
        options = [ "size=80%,mode=0755" ];
        neededForBoot = true;
      };

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
        gid = 994;
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
        "d ${cfg.dirs.lidarrDir} 0775 ${cfg.user} ${cfg.group} -"
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
        package = pkgs-unstable.jellyseerr;
        enable = true;
        openFirewall = false;
        configDir = "${cfg.dirs.jellyseerrDir}";
      };

      systemd.services.jellyseerr = {
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          DynamicUser = lib.mkForce false;
          ReadWritePaths= "${cfg.dirs.jellyseerrDir}";
        };

      };

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

      services.lidarr = {
        package = pkgs-unstable.lidarr;
        enable = true;
        user = "${cfg.user}";
        group = "${cfg.group}";
        dataDir = "${cfg.dirs.lidarrDir}";
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
        package = pkgs-unstable.bazarr;
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
        virtualHosts."lidarr.${cfg.domainName}" = {
    	  sslCertificate = "/data/certificates/fullchain.pem";  # Path to your SSL certificate
    	  sslCertificateKey = "/data/certificates/key.pem";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8686";
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
   paths = [ cfg.dirs.jellyfinDir cfg.dirs.jellyseerrDir cfg.dirs.radarrDir cfg.dirs.sonarrDir cfg.dirs.lidarrDir cfg.dirs.prowlarrDir cfg.dirs.bazarrDir cfg.dirs.sabnzbdDir  ];
   excludePath = [
    "metadata"
    "data"
    "logs"
    "repositories"
    "Definitions"
    "cache"
    "MediaCover"
   ];
  });
}
