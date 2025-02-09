{ cfg, lib, ... }:

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

  shares = [
    {
      source = "/nix/store";
      mountPoint = "/nix/.ro-store";
      tag = "ro-store";
      proto = "virtiofs";
    }
    {
      source = "${cfg.dirs.contentDir}";
      mountPoint = "/data";
      tag = "k3s-cloudflared";
      proto = "virtiofs";
    }
  ];
}
