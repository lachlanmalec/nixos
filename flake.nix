{
  description = "Lachlan Malec's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation = {
      url = "github:nix-community/preservation";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations.asuka = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.preservation.nixosModules.default
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          ./hosts/asuka/configuration.nix
        ];
      };

      nixosConfigurations.kaworu = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.nixosModules.default
          inputs.preservation.nixosModules.default
          inputs.nixos-wsl.nixosModules.default
          inputs.agenix.nixosModules.default
          ./hosts/kaworu/configuration.nix
        ];
      };

      nixosConfigurations.ritsuko = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          inputs.home-manager.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.preservation.nixosModules.default
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          ./hosts/ritsuko/configuration.nix
        ];
      };
    };
}
