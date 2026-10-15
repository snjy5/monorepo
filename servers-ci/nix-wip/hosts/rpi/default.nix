# Raspberry Pi 4 (aarch64), headless, boots through U-Boot/extlinux.
{ inputs, lib, ... }:

{
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  networking.hostName = "nixos-rpi";
  system.stateVersion = "26.05";

  custom = {
    target = "raspberry-pi";
    hasGui = false;
    boot.loader = "extlinux";
  };

  # Matches the stock NixOS SD image layout.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };
}
