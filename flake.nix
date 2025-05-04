# /etc/nixos/flake.nix
{
  description = "NixOS homelab";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Secret management
    sops-nix.url = "github:Mic92/sops-nix";
    # MicroVM
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-24.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = inputs@{ self, nixpkgs, unstable, sops-nix, microvm, home-manager
    , nixvim, ... }: {

      # NixOS configuration for B660-i5-13600 (homelab)
      nixosConfigurations.b660-i5-13600 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          pkgs-unstable = import unstable {
            config.allowUnfree = true;
            config.permittedInsecurePackages = [
              "dotnet-runtime-wrapped-6.0.36"
              "aspnetcore-runtime-6.0.36"
              "aspnetcore-runtime-wrapped-6.0.36"
              "dotnet-sdk-6.0.428"
              "dotnet-sdk-wrapped-6.0.428"
            ];
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
          ./modules/virtual/k3s-cloudflared
        ];
      };

      # Workstation
      nixosConfigurations.dell-i5-7300U = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          ./hosts/dell-i5-7300U
          ./profiles/workstation.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              sharedModules = [ nixvim.homeManagerModules.nixvim ];
              users = { sebastiaan = import ./home/modules/default.nix; };
            };
          }
        ];
      };
    };
}
