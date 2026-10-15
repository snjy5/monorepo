{ config, lib, ... }:

let
  cfg = config.custom;
  isMac = cfg.target == "macbook";
in
{
  config = lib.mkIf (!cfg.isContainerOrAndroid) {
    services = {
      dbus.enable = true;
      fstrim.enable = lib.mkDefault true;

      openssh = {
        enable = true;
        openFirewall = true;
      };

      # Laptop / desktop power control
      tlp.enable = isMac || cfg.target == "generic-desktop";

      # MacBook fan daemon
      mbpfan = lib.mkIf isMac {
        enable = true;
        settings.general = {
          min_fan1_speed = 1300;
          max_fan1_speed = 6200;
          low_temp = 55;
          high_temp = 55;
          max_temp = 55;
          polling_interval = 2;
        };
      };
    };

    virtualisation.docker.enable = lib.mkDefault true;
  };
}
