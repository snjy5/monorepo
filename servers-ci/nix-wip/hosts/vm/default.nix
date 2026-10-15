# Virtual machine guest (qemu/KVM by default; also supports vmware, virtualbox).
{ lib, ... }:

{
  networking.hostName = "nixos-vm";
  system.stateVersion = "26.05";

  custom = {
    target = "vm-guest";
    hasGui = true;
    virtualization.hypervisor = "qemu"; # "qemu" | "vmware" | "virtualbox"
    boot.loader = "grub-bios";
    boot.biosDevice = "/dev/sda";
  };

  # Placeholder layout; imports of a real hardware-configuration.nix win over it.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
