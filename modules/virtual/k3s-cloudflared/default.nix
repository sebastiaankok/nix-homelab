{ pkgs, pkgs-unstable, lib, inputs, self, config, ... }:
with lib;

let
  app = "k3s-cloudflared";

  cfg = {
    dirs = {
      contentDir = config.hostConfig.dataDir + "/k3s-cloudflared";
    };

    user = "k3s-cloudflared";
    group = "k3s-cloudflared";
    uid = 2000;
    gid = 2000;

    vm = {
      hostname = "k3s-cloudflared";
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

      services.k3s = {
        enable = true;
        role = "server";

        extraFlags = [
          #"--disable servicelb" 
          "--disable traefik"
          "--disable local-storage"
          "--disable metrics-server"
          "--disable-network-policy"
        ]
      };

      networking = {
        firewall.allowedTCPPorts = [ 
          443 
          6443
        ];
      };

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
