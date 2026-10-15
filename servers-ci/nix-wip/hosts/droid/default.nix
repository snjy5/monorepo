# nix-on-droid (Termux/PRoot): no kernel, no systemd, so no NixOS `custom.*` options here.
{ pkgs, ... }:

{
  system.stateVersion = "24.05";

  time.timeZone = "Asia/Kolkata";

  environment.packages = with pkgs; [
    git
    openssh
    neovim
    curl
    gnugrep
    gnused
    gnutar
    gzip
    xz
    zip
    unzip
    diffutils
    findutils
    procps
    hostname
  ];

  # The PRoot sandbox cannot do user namespaces.
  nix.extraOptions = ''
    sandbox = false
    experimental-features = nix-command flakes
  '';

  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    config = {
      imports = [ ../../modules/home ];
      home.stateVersion = "24.05";
    };
  };
}
