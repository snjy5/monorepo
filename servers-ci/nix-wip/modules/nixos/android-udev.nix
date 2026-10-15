{ config, lib, ... }:

let
  phone = config.custom.androidPhone;
  match = ''SUBSYSTEM=="usb", ATTR{idVendor}=="${phone.idVendor}"'';
  matchDevice = ''${match}, ATTR{idProduct}=="${phone.idProduct}"'';
in
{
  config = lib.mkIf phone.enable {
    users.groups.adbusers = { };

    services.udev.extraRules = ''
      ${match}, MODE="0660", GROUP="adbusers", TAG+="uaccess"
      ${matchDevice}, SYMLINK+="android_adb"
      ${matchDevice}, SYMLINK+="android_fastboot"
    '';
  };
}
