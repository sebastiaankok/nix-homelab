{ cfg, lib, ... }:
with lib;

let
  # Define a helper function to convert each directory into a share configuration
  toShare = dir: {
    source = dir;
    mountPoint = dir;
    tag = lib.strings.toLower (lib.last (lib.strings.splitString "/" dir));
    proto = "virtiofs";
  };
in
{
  hypervisor = cfg.vm.hypervisor;
  vcpu = cfg.vm.cpu;
  mem = cfg.vm.memory;
  interfaces = [
    {
      id = "${cfg.vm.hostname}";
      mac = "${cfg.vm.mac}";
      type = "macvtap";
      macvtap  = {
        link = "${cfg.vm.interface}";
        mode = "${cfg.vm.network_mode}";
      };
    }
  ];
  #devices = [
  #  {
  #    bus = "pci";
  #    path = "0000:00:02.0";
  #  }
  #];

  shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
    #{
    #  tag = "dri";
    #  source = "/dev/dri";
    #  mountPoint = "/dev/dri";
    #  proto = "9p"; # or "9p" if virtiofs is not supported
    #}
    {
      source = "/var/lib/acme/${cfg.domainName}";
      mountPoint = "/data/certificates";
      tag = "certificate";
      proto = "virtiofs";
    }
  ] ++ (map toShare (builtins.attrValues cfg.dirs)); # Dynamically add shares from cfg.dirs
}
