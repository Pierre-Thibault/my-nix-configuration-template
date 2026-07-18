{
  description = "NixOS configuration template with automatic module importation.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    my-lib.url = "github:Pierre-Thibault/nix-lib";
    my-lib.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      my-lib,
      disko,
      ...
    }:
    let
      userdata = import ./config/userdata.nix;
      inherit (userdata) system;
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          nixos-anywhere
        ];
      };
      nixosConfigurations.${userdata.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          disko.nixosModules.disko
          ./modules/single-disk-layout.nix
          ./configuration.nix
        ];
        specialArgs = {
          inherit self;
          my-lib = my-lib.lib;
          inherit userdata;
          unstable = import nixpkgs-unstable {
            inherit system;
            # config.allowUnfree = true;
          };
        };
      };
    };
}
