# Home Manager config shared by NixOS hosts and nix-on-droid.
# `home.username`, `home.homeDirectory` and `home.stateVersion` are provided by
# whichever integration imports this module.
{ ... }:

{
  programs.home-manager.enable = true;

  # home.packages = with pkgs; [
  #   fastfetch
  #   ripgrep
  # ];
}
