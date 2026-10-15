# ./flake.nix
{
  description = "Portable multi-target NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-on-droid has no release branch newer than 24.05; master tracks current nixpkgs.
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-on-droid,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      # Systems the dev tooling (formatter, devShell) is offered on.
      devSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forDevSystems = f: lib.genAttrs devSystems (system: f nixpkgs.legacyPackages.${system});

      # Every NixOS host shares ./modules/nixos and Home Manager; ./hosts/<name> adds the rest.
      mkNixos =
        system: hostModule:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.hostPlatform = system; }
            home-manager.nixosModules.home-manager
            ./modules/nixos
            hostModule
          ];
        };

      nixosConfigurations = {
        # Bare metal: MacBook Pro 2013/2014 (Haswell)
        nixos = mkNixos "x86_64-linux" ./hosts/macbook;
        # VM guest (qemu/KVM, VMware, VirtualBox)
        nixos-vm = mkNixos "x86_64-linux" ./hosts/vm;
        # Headless server / workstation
        nixos-server = mkNixos "x86_64-linux" ./hosts/server;
        # Raspberry Pi 4
        nixos-rpi = mkNixos "aarch64-linux" ./hosts/rpi;
      };
    in
    {
      inherit nixosConfigurations;

      # Android: nix-on-droid / Termux
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
          overlays = [ nix-on-droid.overlays.default ];
        };
        modules = [ ./hosts/droid ];
        extraSpecialArgs = { inherit inputs; };
      };

      formatter = forDevSystems (pkgs: pkgs.nixfmt);

      devShells = forDevSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.certbot
            pkgs.nixfmt
            pkgs.statix
            pkgs.deadnix
          ];
        };
      });

      # `nix flake check` evaluates (does not build) every host.
      checks = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        lib.mapAttrs' (name: cfg: lib.nameValuePair "host-${name}" cfg.config.system.build.toplevel) (
          lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system) nixosConfigurations
        )
      );
    };
}
