{ config, lib, ... }:

let
  cfg = config.custom;
  isMac = cfg.target == "macbook";
in
{
  config = lib.mkIf (!cfg.isContainerOrAndroid) (
    lib.mkMerge [
      {
        boot = {
          loader = lib.mkMerge [
            { timeout = lib.mkDefault 5; }

            (lib.mkIf (cfg.boot.loader == "grub-efi") {
              efi.canTouchEfiVariables = lib.mkDefault false;
              grub = {
                enable = true;
                efiSupport = true;
                device = "nodev";
                efiInstallAsRemovable = true;
                copyKernels = true;
                useOSProber = true;
              };
            })

            (lib.mkIf (cfg.boot.loader == "grub-bios") {
              grub = {
                enable = true;
                device = cfg.boot.biosDevice;
                copyKernels = true;
              };
            })

            (lib.mkIf (cfg.boot.loader == "extlinux") {
              grub.enable = false;
              generic-extlinux-compatible.enable = true;
            })
          ];

          initrd.kernelModules = [ "btrfs" ] ++ lib.optionals isMac [ "i915" ];

          supportedFilesystems = [
            "btrfs"
            "vfat"
          ];

          tmp = {
            useTmpfs = true;
            cleanOnBoot = true;
          };

          kernelParams = [
            "zswap.enabled=1"
            "zswap.compressor=zstd"
            "zswap.max_pool_percent=70"
            "zswap.shrinker_enabled=1"
          ]
          ++ lib.optionals isMac [
            "acpi_osi="
            "acpi_backlight=native"
            "pcie_aspm=force"
            "i915.enable_psr=0"
            "i915.enable_fbc=1"
          ];

          kernel.sysctl = {
            "vm.swappiness" = 5;
            "vm.oom_dump_tasks" = 1;
            "vm.panic_on_oom" = 0;
            "kernel.sched_autogroup_enabled" = 1;
            "kernel.sysrq" = 1;
          };
        };
      }

      (lib.mkIf isMac {
        boot = {
          kernelModules = [
            "applesmc"
            "coretemp"
            "wl"
          ];
          blacklistedKernelModules = [
            "b43"
            "bcma"
            "brcmsmac"
            "ssb"
          ];
          extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        };

        # `elevator=bfq` no longer exists as a kernel parameter on blk-mq kernels,
        # so select the scheduler through udev instead.
        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
        '';
      })
    ]
  );
}
