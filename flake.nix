# /etc/nixos/flake.nix
{
  description = "NixOS homelab";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    mediaserver.url = "github:nixos/nixpkgs/nixos-unstable";
    immich.url = "github:NixOS/nixpkgs/nixos-24.11";
    # Secret management
    sops-nix.url = "github:Mic92/sops-nix";
    # MicroVM
    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs = inputs@{ self, nixpkgs, mediaserver, immich, sops-nix, microvm, ... }: {

    # NixOS configuration for B660-i5-13600 (homelab)
    nixosConfigurations.b660-i5-13600 = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";

      specialArgs = {
        pkgs-mediaserver = import mediaserver {
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
        pkgs-immich = import immich {
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
