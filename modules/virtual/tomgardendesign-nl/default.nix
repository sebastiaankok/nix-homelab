{ pkgs, pkgs-unstable, lib, inputs, self, config, ... }:
with lib;

let
  app = "tomgardendesign-nl";

  cfg = {
    domainName = "tomgardendesign.nl";
    dirs = {
      contentDir = config.hostConfig.dataDir + "/wordpress/tomgardendesign-nl";
    };

    user = "tomgardendesign-nl";
    group = "tomgardendesign-nl";
    uid = 2000;
    gid = 2000;

    vm = {
      hostname = "tomgardendesign";
      hypervisor = "cloud-hypervisor";
      mac = "12:22:de:ad:be:ea";
      cpu = 2;
      memory = 2048;
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

      services.cloudflared = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        cloudflared 
      ];

      #networking = {
      #  firewall.allowedTCPPorts = [ 443 ];
      #};

      users.groups."${cfg.group}" = {
      	gid = cfg.gid;
      };
      users.users."${cfg.user}" = {
        group = "${cfg.group}";
        isSystemUser = true;
        uid = cfg.uid;
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dirs.contentDir} 0750 ${cfg.user} ${cfg.group} -"
      ];

    };
  };

  #services.restic.backups = (config.lib.hostConfig.mkRestic {
  # inherit app;
  # paths = [ cfg.dirs.contentDir ];
  # excludePath = [
  #  "metadata"
  # ];
  #});
}
