{ config, lib, ... }:

let
  cfg = config.custom;
in
{
  config = lib.mkIf (!cfg.isContainerOrAndroid) (
    lib.mkMerge [
      {
        systemd.user.extraConfig = ''
          DefaultMemoryAccounting=yes
        '';

        systemd.oomd = {
          enable = true;
          enableUserSlices = true;
          enableSystemSlice = true;
        };

        systemd.slices."user-".sliceConfig = {
          ManagedOOMMemoryPressure = "auto";
          ManagedOOMSwap = "auto";
          MemorySwapMax = "infinity";
          MemoryLow = "512M";
        };
      }

      (lib.mkIf cfg.power.disableSleep {
        systemd.sleep.settings.Sleep = {
          AllowSuspend = "no";
          AllowHibernation = "no";
          AllowHybridSleep = "no";
          AllowSuspendThenHibernate = "no";
        };
      })
    ]
  );
}
