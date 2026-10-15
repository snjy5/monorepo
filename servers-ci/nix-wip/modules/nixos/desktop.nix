# Wayland / Sway desktop. Everything here is gated on `custom.hasGui`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom;
in
{
  config = lib.mkIf cfg.hasGui {
    programs = {
      sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      kdeconnect.enable = true; # also opens TCP/UDP 1714-1764
    };

    security.rtkit.enable = true;

    services = {
      libinput.enable = true;
      pipewire = {
        enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
        };
        jack.enable = true;
        wireplumber.enable = true;
      };
    };

    # Screencasting/screenshots for wlroots/sway, FileChooser, AppChooser, ...
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default = [ "gtk" ];
        sway = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
      };
    };

    environment = {
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
      };
      systemPackages = with pkgs; [
        wl-clipboard
        fuzzel
        brightnessctl
        gammastep
        bemenu
        foot
        waybar
        wf-recorder
        swaybg
        swayidle
        swaylock
        firefox
        mupdf
        imv
        mpv
      ];
    };

    fonts.packages = with pkgs; [
      noto-fonts
      font-awesome
      nerd-fonts.jetbrains-mono
    ];

    # Virtual webcam for screen sharing.
    boot = {
      kernelModules = [ "v4l2loopback" ];
      extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
      extraModprobeConfig = ''
        options v4l2loopback devices=1 exclusive_caps=1 video_nr=1 card_label="VirtualCam"
      '';
    };
  };
}
