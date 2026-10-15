{ config, lib, ... }:

{
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = config.custom.timeZone;
  console.keyMap = config.custom.keyMap;

  security.polkit.enable = lib.mkDefault (!config.custom.isContainerOrAndroid);
}
