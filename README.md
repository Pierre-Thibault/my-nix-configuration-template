# my-nix-configuration-template

Flake templates for NixOS configurations with automatic module
importation (via [nix-lib](https://github.com/Pierre-Thibault/nix-lib)).

## Templates

### `qemu-guest` (default)

NixOS for KVM/QEMU cloud virtual machines, deployed remotely with
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere):

- [disko](https://github.com/nix-community/disko) declarative disk
  layout (GPT, hybrid BIOS/UEFI boot with GRUB `efiInstallAsRemovable`)
- `qemu-guest` profile (virtio drivers in the initrd)
- OpenSSH enabled, root access by SSH key only
- Dev shell providing `nixos-anywhere`

```bash
nix flake init -t github:Pierre-Thibault/my-nix-configuration-template#qemu-guest
# or, since it is the default template:
nix flake init -t github:Pierre-Thibault/my-nix-configuration-template
```

First deployment (repartitions the target disk!):

```bash
nix develop
nixos-anywhere --flake .#<hostname> root@<ip>
```

Subsequent updates:

```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<ip>
```

### `desktop`

Desktop NixOS configuration with the same structure (automatic module
importation, `userdata.nix`), without the remote-deployment machinery.

```bash
nix flake init -t github:Pierre-Thibault/my-nix-configuration-template#desktop
```

## Configuration

Both templates read per-host data from `config/userdata.nix`:

```nix
{
  hostname = "myhost";          # also the attribute name in nixosConfigurations
  system = "x86_64-linux";      # or "aarch64-linux"
  mainDisk = "/dev/sda";        # qemu-guest only; /dev/vda on some providers
  opensshKeys = [ "ssh-ed25519 AAAA..." ];
  stateVersion = "26.05";       # set once at install time, never change
}
```

Every `.nix` file under `modules/` is imported automatically — add or
remove a module file, no `imports` list to maintain.

## Notes

- The `nixosConfigurations` attribute is named after `userdata.hostname`;
  with a matching machine hostname, plain `nixos-rebuild switch --flake .`
  resolves it automatically.
- Flakes only see files tracked by Git: `git add` new files (including
  `config/userdata.nix`) before building.
