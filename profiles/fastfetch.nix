{lib, ...}: let
  priorityList = import ../utils/priorityList.nix {inherit lib;};
  inherit (priorityList) listToPriorityList;
in {
  atro.fastfetch = {
    enable = true;

    modules = listToPriorityList 0 [
      "title"
      "separator" # General OS information
      "uptime"
      "os"
      "kernel"
      "packages"
      "processes"
      "battery"
      "poweradapter"
      "separator" # Compute (CPU, GPU)
      "cpu"
      "loadavg"
      "gpu"
      "separator" # Storage devices (NVMe, Memory, Swap, etc.)
      "memory"
      "swap"
      "disk"
      "zpool"
      "separator" # External connectivity (Ethernet, Wi-Fi, Bluetooth, etc.)
      "localip"
      "dns"
      "wifi"
      "bluetooth"
      "separator" # Regular services
      {
        "type" = "command";
        "text" = "systemctl is-active attic-client";
        "key" = "Attic";
      }
      {
        "type" = "command";
        "text" = "systemctl is-active --user atuin-daemon";
        "key" = "Atuin";
      }
      {
        "type" = "command";
        "text" = "systemctl is-active docker";
        "key" = "Docker";
      }
      {
        "type" = "command";
        "text" = "systemctl is-active kopia";
        "key" = "Kopia";
      }
    ];
  };
}
