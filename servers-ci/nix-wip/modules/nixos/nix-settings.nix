{ lib, ... }:

{
  nix = {
    channel.enable = false;
    nixPath = [ ];

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      fallback = false;
      max-jobs = "auto";

      # Downloads
      max-substitution-jobs = 128;
      http-connections = 50;
      http2 = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    # Broadcom wl driver (MacBook Wi-Fi) is marked insecure.
    allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";
  };
}
