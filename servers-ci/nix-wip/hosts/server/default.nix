# Headless x86_64 server / IaC workstation.
{ lib, ... }:

{
  networking.hostName = "nixos-server";
  system.stateVersion = "26.05";

  custom = {
    target = "server";
    hasGui = false;
  };

  # Placeholder layout; imports of a real hardware-configuration.nix win over it.
  fileSystems = {
    "/" = lib.mkDefault {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = lib.mkDefault {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
}
