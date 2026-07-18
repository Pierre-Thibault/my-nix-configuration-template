# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  unstable,
  userdata,
  my-lib,
  ...
}:

let
  inherit (userdata) username;
in
{
  imports = (my-lib.modules ./modules);

}
