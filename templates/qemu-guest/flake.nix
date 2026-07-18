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
      targetHost = userdata.targetHost or userdata.hostname;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixos-anywhere
        ];
        shellHook = ''
          echo ""
          echo "  ${userdata.hostname} — deployment commands:"
          echo ""
          echo "    nix run .#install   First-time install via nixos-anywhere (REPARTITIONS THE DISK)"
          echo "    nix run .#deploy    Rebuild and switch the remote host"
          echo ""
        '';
      };

      apps.${system} = {
        install = {
          type = "app";
          meta.description = "First-time install via nixos-anywhere (REPARTITIONS THE DISK)";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellApplication {
              name = "install";
              runtimeInputs = [ pkgs.nixos-anywhere ];
              text = ''
                nixos-anywhere --flake ".#${userdata.hostname}" "root@${targetHost}"
              '';
            }
          );
        };
        deploy = {
          type = "app";
          meta.description = "Rebuild and switch the remote host";
          program = nixpkgs.lib.getExe (
            pkgs.writeShellApplication {
              name = "deploy";
              runtimeInputs = [ pkgs.nixos-rebuild ];
              text = ''
                nixos-rebuild switch \
                  --flake ".#${userdata.hostname}" \
                  --target-host "root@${targetHost}"
              '';
            }
          );
        };
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
