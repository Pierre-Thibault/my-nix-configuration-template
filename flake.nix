{
  outputs =
    { ... }:
    {
      templates = {
        "nixos-26.05".path = ./templates/nixos-26.05;
        default.path = ./templates/nixos-26.05;
        "qemu-guest.nix".path = ./templates/qemu-guest.nix;
      };
    };
}
