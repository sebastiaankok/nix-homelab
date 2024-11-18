# /etc/nixos/flake.nix
{
  description = "NixOS homelab";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Secret management
    sops-nix.url = "github:Mic92/sops-nix";
    # MicroVM
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, sops-nix, microvm, ... }: {
    # NixOS configuration for temptop (temp homelab laptop)
    nixosConfigurations.dell-i5-7300U = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          config.allowUnfree = true;
          inherit system;
        };
      };

      modules = [
        sops-nix.nixosModules.sops
        microvm.nixosModules.host
        ./hosts/dell-i5-7300U
        ./profiles
        ./modules
        ./modules/virtual/mediaserver/default.nix
      ];
    };

    # NixOS configuration for B660-i5-13600 (homelab)
    nixosConfigurations.b660-i5-13600 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          config.allowUnfree = true;
          inherit system;
        };
      };

      modules = [
        sops-nix.nixosModules.sops
        microvm.nixosModules.host
	      ./hosts/b660-i5-13600
        ./profiles
        ./modules
        ./modules/virtual/mediaserver/default.nix
        ./modules/virtual/tomgardendesign-nl
      ];
    };

  };
}
