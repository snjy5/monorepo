# Mount options and swapfile on top of the generated hardware-configuration.nix.
# Devices and subvolumes stay in the generated file so regenerating it is safe.
{ lib, ... }:

let
  btrfsOptions = [
    "noatime"
    "discard=async"
    "space_cache=v2"
  ];
in
{
  fileSystems = lib.genAttrs [ "/" "/snapshots" "/swap" ] (_: {
    options = btrfsOptions;
  })
  // {
    "/boot".options = [ "shortname=winnt" ];
  };

  # NixOS creates this with `btrfs filesystem mkswapfile` (NOCOW) when missing.
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 10 * 1024; # MiB
    }
  ];
}
