{ lib, config, ... }:

let
  hypervisor = config.custom.virtualization.hypervisor;
in
{
  config = lib.mkMerge [
    (lib.mkIf (hypervisor == "vmware") {
      virtualisation.vmware.guest.enable = true;
    })
    (lib.mkIf (hypervisor == "virtualbox") {
      virtualisation.virtualbox.guest.enable = true;
    })
    (lib.mkIf (hypervisor == "qemu") {
      services.qemuGuest.enable = true;
      services.spice-vdagentd.enable = config.custom.hasGui;
    })
  ];
}
