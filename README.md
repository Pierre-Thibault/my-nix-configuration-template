# my-nix-configuration-template

A [Nix flake template](https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake-init) for bootstrapping a NixOS configuration with automatic module importation.

## What it provides

The `nixos-26.05` template sets up a flake-based NixOS configuration built on `nixpkgs` `nixos-26.05`, alongside an `unstable` channel available via `nixpkgs-unstable` for packages you want to pull from `nixos-unstable`.

Modules under `modules/` are imported automatically using [`my-lib`](https://github.com/Pierre-Thibault/nix-lib), so you don't need to list every module by hand in `configuration.nix`.

## Usage

Initialize a new configuration from this template:

```sh
nix flake init -t github:Pierre-Thibault/my-nix-configuration-template#nixos-26.05
```

Then edit `config/userdata.nix` with your system's details:

```nix
{
  hostname = "";
  system = "x86_64";
  userfullname = "";
  username = "";
}
```

Add your NixOS modules under `modules/` — they will be picked up automatically by `configuration.nix` via `my-lib.modules`.

Build and switch to the new configuration:

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

## Structure

```
nixos-26.05/
├── flake.nix           # Flake inputs and nixosConfigurations output
├── configuration.nix   # Top-level NixOS configuration (auto-imports modules/)
└── config/
    └── userdata.nix     # Per-machine user/host settings
```

## License

MIT — see [LICENSE](LICENSE).
