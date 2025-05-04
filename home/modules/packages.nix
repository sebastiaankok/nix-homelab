{pkgs, ...}:
{
  nixpkgs.config = { allowUnfree = true; };

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
    obsidian

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
