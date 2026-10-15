{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom;
  isMac = cfg.target == "macbook";
  isBareMetal = !cfg.isContainerOrAndroid && cfg.virtualization.hypervisor == "none";
in
{
  config = lib.mkIf (!cfg.isContainerOrAndroid) {
    hardware = {
      enableRedistributableFirmware = lib.mkDefault isBareMetal;

      cpu.intel.updateMicrocode = lib.mkIf isMac (lib.mkDefault true);

      graphics = lib.mkIf cfg.hasGui {
        enable = true;
        extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 (
          [ pkgs.libvdpau-va-gl ]
          # Haswell (MacBook Pro 2013/2014) predates intel-media-driver's Broadwell+ support.
          ++ (if isMac then [ pkgs.intel-vaapi-driver ] else [ pkgs.intel-media-driver ])
        );
      };

      bluetooth.enable = lib.mkDefault (cfg.hasGui && isBareMetal);

      # The module also loads the kernel module and ships firmware + calibration.
      facetimehd = lib.mkIf isMac {
        enable = true;
        withCalibration = true;
      };
    };
  };
}
