# /etc/nixos/flake.nix
{
  description = "NixOS homelab";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Secret management
    sops-nix.url = "github:Mic92/sops-nix";

  };
  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, sops-nix, ... }: {

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
        ./hosts/dell-i5-7300U
        ./profiles
        ./modules
      ];
    };
  };
}
