{ config, lib, pkgs, ... }:
{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    powertop
    cpufrequtils
    pciutils
    brightnessctl
    sysz
    intel-gpu-tools
    nh
  ];

  system.stateVersion = "24.05"; # Did you read the comment?

}

