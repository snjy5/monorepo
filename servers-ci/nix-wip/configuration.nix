# ./configuration.nix
{
  config,
  pkgs,
  lib,
  ...
}:

let
  # ===========================================================================
  # GLOBAL VARIABLES
  # ===========================================================================
  globals = {
    username = "void";
    initialPassword = "1234";
    hostname = "nixos";
    timeZone = "Asia/Kolkata";
    keyMap = "us";
    stateVersion = "26.05";

    # Disk & Encryption (Overridden per-host via _module.args if needed)
    luksUuid = null;

    # Devices
    androidPhone = {
      # Motorola PCS XT1541 [Moto G 3rd Gen]
      idVendor = "22b8";
      idProduct = "2e82";
    };
  };
in
{
  # Expose globals to all imported modules as module arguments
  _module.args = {
    globals = lib.mkDefault globals;
  };

  imports = [
    # Custom profile declarations & hardware abstraction
    ./modules/profiles.nix

    # Core system configurations
    ./modules/btrfs-snapshots.nix
    ./modules/nix-settings.nix
    ./modules/home-manager.nix
    ./modules/boot-hardware.nix
    ./modules/filesystems.nix
    ./modules/systemd-oom.nix
    ./modules/services.nix
    ./modules/network-security.nix
    ./modules/programs-shell.nix
    ./modules/environment-packages.nix
    ./modules/users.nix
  ];

  system.stateVersion = config._module.args.globals.stateVersion;
}
