# Every host-specific knob lives under `config.custom`.
# Hosts (./hosts/*) set these; the other modules only read them.
{ lib, config, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.custom = {
    target = mkOption {
      type = types.enum [
        "macbook"
        "generic-desktop"
        "vm-guest"
        "server"
        "raspberry-pi"
        "chroot"
      ];
      default = "generic-desktop";
      description = "Target hardware profile.";
    };

    isContainerOrAndroid = mkOption {
      type = types.bool;
      default = false;
      description = "Enable inside chroot/proot-like environments without kernel or systemd control.";
    };

    hasGui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Wayland, Sway, GUI applications and audio stack.";
    };

    virtualization.hypervisor = mkOption {
      type = types.enum [
        "none"
        "vmware"
        "virtualbox"
        "qemu"
      ];
      default = "none";
      description = "Guest hypervisor integrations to enable.";
    };

    boot = {
      loader = mkOption {
        type = types.enum [
          "grub-efi"
          "grub-bios"
          "extlinux"
        ];
        default = "grub-efi";
        description = ''
          Boot loader flavour. `grub-efi` installs to the removable EFI path,
          `grub-bios` installs to `custom.boot.biosDevice`, `extlinux` is for
          U-Boot boards such as the Raspberry Pi.
        '';
      };
      biosDevice = mkOption {
        type = types.str;
        default = "/dev/sda";
        description = "Disk GRUB is installed to when `custom.boot.loader = \"grub-bios\"`.";
      };
    };

    user = {
      name = mkOption {
        type = types.str;
        default = "void";
        description = "Primary (wheel) user.";
      };
      initialPassword = mkOption {
        type = types.str;
        default = "1234";
        description = ''
          Initial password for the primary user and root. Only used on first
          activation; change it with `passwd` right after installing.
        '';
      };
    };

    timeZone = mkOption {
      type = types.str;
      default = "Asia/Kolkata";
      description = "System time zone.";
    };

    keyMap = mkOption {
      type = types.str;
      default = "us";
      description = "Console keymap.";
    };

    power.disableSleep = mkEnableOption "disabling suspend, hibernate and hybrid sleep";

    androidPhone = {
      enable = mkEnableOption "udev rules for adb/fastboot access to an Android phone";
      idVendor = mkOption {
        type = types.str;
        default = "22b8";
        description = "USB vendor id (Motorola).";
      };
      idProduct = mkOption {
        type = types.str;
        default = "2e82";
        description = "USB product id (Moto G 3rd Gen, XT1541).";
      };
    };
  };

  # Containers never have a GUI. This depends only on `isContainerOrAndroid`,
  # so it cannot recurse into `hasGui` itself.
  config.custom.hasGui = lib.mkIf config.custom.isContainerOrAndroid (lib.mkForce false);
}
