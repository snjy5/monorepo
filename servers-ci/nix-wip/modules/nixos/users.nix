{ config, lib, pkgs, ... }:

let
  cfg = config.custom;
in
{
  users.users = {
    root.initialPassword = cfg.user.initialPassword;

    ${cfg.user.name} = {
      isNormalUser = true;
      initialPassword = cfg.user.initialPassword;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "input"
      ]
      ++ lib.optional config.virtualisation.docker.enable "docker"
      ++ lib.optional cfg.androidPhone.enable "adbusers";
    };
  };

  programs.zsh.enable = true;
}
