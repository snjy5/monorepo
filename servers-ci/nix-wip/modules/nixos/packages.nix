{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom;
  isLaptopLike = cfg.target == "macbook" || cfg.target == "generic-desktop";
in
{
  environment.systemPackages =
    with pkgs;
    [
      # Portable base CLI
      git
      file
      htop
      wget
      curl
      neovim
      tmux
      stress
      cacert
      pciutils
      usbutils
      e2fsprogs
      unzip
      python3
    ]
    ++ lib.optionals (!cfg.isContainerOrAndroid) [
      btrfs-progs
      smartmontools
    ]
    ++ lib.optionals (cfg.boot.loader == "grub-efi") [ efibootmgr ]
    ++ lib.optionals isLaptopLike [ powertop ];
}
