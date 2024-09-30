# /etc/nixos/flake.nix
{
  description = "NixOS homelab";

  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
        ./hosts/dell-i5-7300U
        ./profiles
        ./modules
        microvm.nixosModules.host
        {
          microvm.vms = {
            test = {
              # The package set to use for the microvm. This also determines the microvm's architecture.
              # Defaults to the host system's package set if not given.
              pkgs = import nixpkgs {system = "x86_64-linux";};

              # (Optional) A set of special arguments to be passed to the MicroVM's NixOS modules.
              #specialArgs = {};

              # The configuration for the MicroVM.
              # Multiple definitions will be merged as expected.
              config = import ./hosts/vm-test/default.nix;
            };
          };
	      }
      ];
    };
  };
}
