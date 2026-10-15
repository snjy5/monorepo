{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.btrfs.snapshots;

  snapScript = pkgs.writeShellApplication {
    name = "btrfs-snapshots";
    runtimeInputs = [
      pkgs.btrfs-progs
      pkgs.coreutils
    ];
    text = ''
      date="$(date '+%d-%m-%Y')"
      rootfs="/snapshots/$date"

      mkdir -p /snapshots

      # Replace an existing snapshot taken on the same day.
      if [ -d "$rootfs" ]; then
        btrfs subvolume delete "$rootfs" || true
      fi

      # Read-only snapshot of /
      btrfs subvolume snapshot -r / "$rootfs"
    '';
  };
in
{
  options.custom.btrfs.snapshots = {
    enable = lib.mkEnableOption "periodic read-only btrfs snapshots of /";

    interval = lib.mkOption {
      type = lib.types.str;
      default = "6h";
      description = "Time between snapshots (systemd OnUnitActiveSec).";
    };

    onBootSec = lib.mkOption {
      type = lib.types.str;
      default = "15m";
      description = "Delay after boot for the first run (systemd OnBootSec).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."btrfs-snapshots.sh".source = lib.getExe snapScript;

    systemd.services.btrfs-snapshots = {
      description = "Create read-only btrfs snapshot of /";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe snapScript;
      };
    };

    systemd.timers.btrfs-snapshots = {
      description = "Run btrfs-snapshots on a timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = cfg.onBootSec;
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
      };
    };
  };
}
