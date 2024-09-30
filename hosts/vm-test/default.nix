{
  config,
  lib,
  pkgs,
  ...
}: {
  microvm = {
    hypervisor = "cloud-hypervisor";
    vcpu = 1;
    mem = 1024;
    interfaces = [
      {
        type = "macvtap";
        mode = "private";
        id = "vm-test";
        mac = "02:22:de:ad:be:ea";
      }
    ];

    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];
  };

  # Normal NixOS configuration past this point

  systemd.network.enable = true;

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "ether";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA = true;
    };
  };

  networking = {
    hostName = "vm-test";
    firewall.package = pkgs.nftables;
    nftables.enable = true;
  };

  services.prometheus = {
    enable = true;
  };

  system.stateVersion = "24.05";
}
