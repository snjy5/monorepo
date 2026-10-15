# Shared by every NixOS host. Per-host choices go through `custom.*` options.
{
  imports = [
    ./options.nix
    ./virtualization-guests.nix
    ./nix-settings.nix
    ./boot.nix
    ./hardware.nix
    ./services.nix
    ./networking.nix
    ./systemd-oom.nix
    ./desktop.nix
    ./packages.nix
    ./users.nix
    ./android-udev.nix
    ./btrfs-snapshots.nix
    ./home-manager.nix
  ];
}
