{
  description = "NixOS configuration template with automatic module importation.";

  inputs =
    let
      systemVersion = (import ./config/userdata.nix).systemVersion;
    in
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-${systemVersion}";
      nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
      my-lib.url = "github:Pierre-Thibault/nix-lib";
      my-lib.inputs.nixpkgs.follows = "nixpkgs";
    };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      my-lib,
      ...
    }:
    let
      userdata = import ./config/userdata.nix;
      inherit (userdata) system;
    in
    {
      nixosConfigurations.${userdata.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
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
