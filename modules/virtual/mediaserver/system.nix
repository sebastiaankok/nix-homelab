{ cfg, ... }:
{
  system.stateVersion = "24.05";

  # Create a new user
  users.users."${cfg.vm.user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$4mHF1epbQ8m2uCgNnezmP0$B/JNxHj9mzH2i9qqBerYoMaNWqthDIGuZSB1fuUJid2";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTvwNAE0ZUIgEZRlZqw48o5Sw8gZuCPaYUPUHEp/vtg sebastiaan@linux.com"
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  systemd.network.networks."20-lan" = {
    matchConfig.Type = "${cfg.vm.interface}";
    networkConfig = {
      DHCP = "yes";
      IPv6AcceptRA= "no";
    };
  };

  networking = {
    hostName = "${cfg.vm.hostname}";
  };
}
