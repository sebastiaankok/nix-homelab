{ config, lib, pkgs, ... }:
{
  imports = [
    ./editor/neovim
    ./shell/zsh
    ./shell/atuin
    ./shell/kubeswitch
    ./gui/ghostty
  ];

  # Home-manager defaults
  home.stateVersion = "24.11";

  home.username = "sebastiaan";
  home.homeDirectory = "/home/sebastiaan";


  programs = {
    home-manager.enable = true;
    nixvim.enable = true;
  };

  programs.git = {
    enable = true;
    userEmail = "sebastiaan@linux.com";
    userName = "Sebastiaan Kok";
    extraConfig = {
      color = { ui = true; };
      core = { pager = "diff-so-fancy | less --tabs=4 -RF"; };
      interactive = {diffFilter = "diff-so-fancy --patch"; };
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    # languages
    python3
    python311Packages.pip
    pipx
    pre-commit
    virtualenv
    go

    # language utils
    black
    isort
    djlint
    nixfmt-classic
    prettierd
    shellcheck
    stylua
    taplo
    yamlfmt

    # system tools
    yq
    jq
    coreutils-full
    tree
    nettools
    vivid
    diff-so-fancy
    ripgrep
    eza
    lazygit
    btop
    nh
    sops
    bat

    # network
    nmap

    # containers
    docker-client
    colima

    # databases
    postgresql

    # ci tools
    gitleaks
    rclone
    restic
    ssh-to-age

    # k8s
    k9s
    kubectl
    kubecolor
    krew


  ];

}
