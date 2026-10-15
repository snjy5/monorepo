# nix-flake

Multi-target Nix flake: one shared module set, one small file per host.

## Hosts

| Output                                | Target                            | Build / switch                                          |
| ------------------------------------- | --------------------------------- | ------------------------------------------------------- |
| `nixosConfigurations.nixos`           | MacBook Pro 11,1 (Haswell, LUKS + btrfs) | `sudo nixos-rebuild switch --flake .#nixos`      |
| `nixosConfigurations.nixos-vm`        | VM guest (qemu / vmware / virtualbox) | `sudo nixos-rebuild switch --flake .#nixos-vm`      |
| `nixosConfigurations.nixos-server`    | Headless x86_64 server            | `sudo nixos-rebuild switch --flake .#nixos-server`      |
| `nixosConfigurations.nixos-rpi`       | Raspberry Pi 4 (aarch64)          | `sudo nixos-rebuild switch --flake .#nixos-rpi`         |
| `nixOnDroidConfigurations.default`    | Android via nix-on-droid          | `nix-on-droid switch --flake .#default`                 |

## Layout

```
flake.nix                       inputs + one-line host definitions
hosts/<name>/default.nix        everything that differs per host (sets `custom.*`)
hosts/macbook/                  hardware-configuration.nix (generated) + filesystems.nix
modules/nixos/                  shared NixOS modules, one concern per file
modules/nixos/options.nix       all `custom.*` options (target, hasGui, boot loader, user, ...)
modules/home/default.nix        Home Manager config, used by NixOS hosts and nix-on-droid
```

Add a host: create `hosts/<name>/default.nix`, set `custom.target`, `custom.hasGui` and
`system.stateVersion`, then add one `mkNixos "<system>" ./hosts/<name>` line in `flake.nix`.

## Notes

- `custom.hasGui = false` turns off Sway, PipeWire, portals, fonts and GUI packages.
- Replace the placeholder `fileSystems` in `hosts/vm`, `hosts/server` with a generated
  `hardware-configuration.nix` for real installs.
- Change the default password (`custom.user.initialPassword`, `1234`) with `passwd` after first boot.
- nix-on-droid follows its `master` branch (there is no release branch newer than 24.05).
  Run `nix flake lock` once so the lock file picks it up.
- Dev tooling: `nix fmt`, `nix develop` (nixfmt, statix, deadnix, certbot) on Linux and macOS.

## Features

- [x] Btrfs snapshots (`custom.btrfs.snapshots.enable`)
- [x] Home Manager
- [x] MacBook Pro 2013/2014 (Intel) support
- [x] Low RAM optimised (zswap, oomd, swapfile)
- [x] Wayland only
