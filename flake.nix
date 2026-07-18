{
  outputs =
    { self, ... }:
    {
      templates = {
        "desktop" = {
          path = ./templates/desktop;
          description = "Desktop NixOS configuration with automatic module importation";
        };
        qemu-guest = {
          path = ./templates/qemu-guest;
          description = "NixOS for KVM/QEMU cloud VMs via nixos-anywhere (disko, GRUB hybrid)";
        };
        default = self.templates.qemu-guest;
      };
    };
}
