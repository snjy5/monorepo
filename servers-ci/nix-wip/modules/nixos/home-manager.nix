# NixOS-side wiring for Home Manager. The user's actual config lives in ../home.
{ config, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";

    users.${config.custom.user.name} = {
      imports = [ ../home ];
      home.stateVersion = config.system.stateVersion;
    };
  };
}
