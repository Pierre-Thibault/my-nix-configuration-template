# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  modulesPath,
  userdata,
  my-lib,
  ...
}:
let
  inherit (userdata) mainDisk;
in
{
  imports = (my-lib.modules ./modules) ++ [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  disko.devices.disk.main.device = mainDisk;

  boot.loader.grub = {
    devices = [ mainDisk ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = userdata.opensshKeys;

  system.stateVersion = userdata.systemStateVersion;
}
